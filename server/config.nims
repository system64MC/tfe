rmdir("out")
mkdir("out")
--outdir:"out/"
switch("define", "normDebug")
--threads:on
--stacktrace:on
--linetrace:on
--deepcopy:on
# --debugger:native
cpDir("../libs/", "out/")
mkdir("out/assets")
cpDir("../assets", "out/assets")