{
  lib,
  stdenv,
  coreutils,
  writeShellScript,
  makeDesktopItem,
  kernel,
  glfw3,
  zenity,
  copyDesktopItems,
  autoPatchelfHook,
  makeWrapper,
  yeetmouse-src,
  # Allow overriding these for CachyOS/LLVM kernels
  kernelModuleMakeFlags ? null,
}:

let
  actualKernelModuleMakeFlags =
    if kernelModuleMakeFlags != null then kernelModuleMakeFlags else kernel.makeFlags;
in
stdenv.mkDerivation {
  pname = "yeetmouse";
  version =
    let
      json = lib.importJSON ./version.json;
    in
    json.version;

  src = yeetmouse-src;

  setSourceRoot = "export sourceRoot=$(pwd)/source";
  nativeBuildInputs = kernel.moduleBuildDependencies ++ [
    makeWrapper
    autoPatchelfHook
    copyDesktopItems
  ];
  buildInputs = [
    stdenv.cc.cc.lib
    glfw3
  ];

  makeFlags = actualKernelModuleMakeFlags ++ [
    "KBUILD_OUTPUT=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(sourceRoot)/driver"
  ];

  preBuild = ''
    # Upstream removed config.sample.h; create config.h from defaults.h
    # The Makefile expects config.h to exist (cp -n config.sample.h config.h)
    if [ ! -f $sourceRoot/driver/config.h ]; then
      cp $sourceRoot/driver/defaults.h $sourceRoot/driver/config.h
    fi
  '';

  LD_LIBRARY_PATH = "/run/opengl-driver/lib:${
    lib.makeLibraryPath [
      stdenv.cc.cc.lib
      glfw3
    ]
  }";

  postBuild = ''
    make "-j$NIX_BUILD_CORES" -C $sourceRoot/gui "M=$sourceRoot/gui" "LIBS=-lglfw -lGL"
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
