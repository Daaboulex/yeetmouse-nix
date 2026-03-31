{
  lib,
  stdenv,
  llvmPackages_latest,
  coreutils,
  writeShellScript,
  makeDesktopItem,
  kernel,
  glfw3,
  zenity,
  copyDesktopItems,
  autoPatchelfHook,
  makeWrapper,
  pkg-config,
  yeetmouse-src,
}:

let
  # Auto-detect if kernel uses LLVM/Clang (CachyOS LTO, etc.)
  kernelNameLower = lib.toLower (kernel.pname or kernel.name or "");
  kernelUsesLLVM =
    (builtins.match ".*cachyos.*" kernelNameLower != null)
    || lib.any (f: lib.hasPrefix "LLVM=1" f || lib.hasPrefix "CC=clang" f) (kernel.makeFlags or [ ]);

  buildStdenv = if kernelUsesLLVM then llvmPackages_latest.stdenv else stdenv;

  llvmMakeFlags = lib.optionals kernelUsesLLVM [
    "LLVM=1"
    "CC=clang"
    "LD=ld.lld"
    "KCFLAGS=-Wno-unused-command-line-argument"
  ];
in
buildStdenv.mkDerivation {
  pname = "yeetmouse";
  version =
    let
      json = lib.importJSON ./version.json;
    in
    json.version;

  src = yeetmouse-src;

  setSourceRoot = "export sourceRoot=$(pwd)/source";
  nativeBuildInputs =
    kernel.moduleBuildDependencies
    ++ [
      makeWrapper
      autoPatchelfHook
      copyDesktopItems
      pkg-config
    ]
    ++ lib.optionals kernelUsesLLVM [ llvmPackages_latest.lld ];
  buildInputs = [
    buildStdenv.cc.cc.lib
    glfw3
  ];

  makeFlags = llvmMakeFlags ++ [
    "KBUILD_OUTPUT=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  preBuild = ''
    # Upstream removed config.sample.h; create config.h from defaults.h
    if [ ! -f $sourceRoot/driver/config.h ]; then
      if [ -f $sourceRoot/driver/defaults.h ]; then
        cp $sourceRoot/driver/defaults.h $sourceRoot/driver/config.h
      elif [ -f $sourceRoot/driver/config.sample.h ]; then
        cp $sourceRoot/driver/config.sample.h $sourceRoot/driver/config.h
      fi
    fi

    # Set M= here where $sourceRoot is available as a shell variable
    makeFlagsArray+=("M=$sourceRoot/driver")
  '';

  LD_LIBRARY_PATH = "/run/opengl-driver/lib:${
    lib.makeLibraryPath [
      buildStdenv.cc.cc.lib
      glfw3
    ]
  }";

  postBuild =
    let
      cxx = if kernelUsesLLVM then "CXX=clang++" else "";
    in
    ''
      make -j"$NIX_BUILD_CORES" ${cxx} -C "$sourceRoot/gui" M="$sourceRoot/gui" LIBS="-lglfw -lGL"
    '';

  postPatch = ''
    # Convert informational printk to KERN_INFO
    sed -i 's/printk(/printk(KERN_INFO /g' driver/driver.c

    # Convert Error printk to KERN_ERR
    sed -i 's/printk(/printk(KERN_ERR /g' driver/accel_modes.c

    # Fix GUI hardcoded limits for Smoothness (exponent)
    # Allow Jump mode to show 0.00
    sed -i 's/DragFloat("##Exp_Param", \&params\[selected_mode\].exponent, 0.0, 0.01/DragFloat("##Exp_Param", \&params\[selected_mode\].exponent, 0.0, 0.0/g' gui/main.cpp
    sed -i 's/SliderFloat("##Exp_Param", \&params\[selected_mode\].exponent, 0.0, 1/SliderFloat("##Exp_Param", \&params\[selected_mode\].exponent, 0.0, 1/g' gui/main.cpp

    # Hide "Running without root privileges" warning and force has_privilege = true
    sed -i 's/if (getuid()) {/if (false) { \/\/ getuid check disabled/g' gui/main.cpp
    sed -i 's/has_privilege = false;/has_privilege = true; \/\/ forced/g' gui/main.cpp
    sed -i 's/ImGui::GetForegroundDrawList()->AddText(ImVec2(10, ImGui::GetWindowHeight() - 40),/if(false) ImGui::GetForegroundDrawList()->AddText(ImVec2(10, ImGui::GetWindowHeight() - 40),/g' gui/main.cpp

    # Exclude uinput virtual devices from driver_match — prevents yeetmouse from
    # attaching to StreamController/etc. virtual input devices that report BUS_USB
    # but are actually uinput devices with generic vendor/product IDs.
    # These devices have broad key capabilities that logind monitors for system
    # power keys, causing session crashes when yeetmouse transforms events on them.
    # Real USB mice have real vendor IDs (e.g., 046D for Logitech).
    # keyd uses BUS_USB with vendor=0x0001 but it has a parent HID device, so it
    # matches the HID path above (lines 158-162) and is unaffected by this filter.
    sed -i '/handle other non-HID devices/,/return false;/{
      /if (dev->id.bustype == BUS_USB/c\    if ((dev->id.bustype == BUS_USB || dev->id.bustype == BUS_VIRTUAL) \&\& dev->id.vendor != 0x0001) {
    }' driver/driver.c
  '';

  postInstall = ''
    install -Dm755 $sourceRoot/gui/YeetMouseGui $out/bin/yeetmouse
    wrapProgram $out/bin/yeetmouse \
      --prefix PATH : ${lib.makeBinPath [ zenity ]}

    # Install Raw Accel icon
    install -Dm644 ${./icons/rawaccel.png} $out/share/icons/hicolor/256x256/apps/rawaccel.png
  '';

  buildFlags = [ "modules" ];
  installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];
  installTargets = [ "modules_install" ];

  desktopItems = [
    (makeDesktopItem {
      name = "yeetmouse";
      exec = writeShellScript "yeetmouse.sh" ''
        "yeetmouse"
      '';
      type = "Application";
      desktopName = "Yeetmouse GUI";
      comment = "Yeetmouse Configuration Tool";
      icon = "rawaccel";
      categories = [
        "Settings"
        "HardwareSettings"
      ];
    })
  ];

  meta = {
    description = "YeetMouse — kernel mouse acceleration driver with GUI";
    homepage = "https://github.com/AndyFilter/YeetMouse";
    license = lib.licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "yeetmouse";
  };
}
