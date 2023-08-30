rmdir("out")
mkdir("out")
--outdir:"out/"
--threads:on
--stacktrace:on
--linetrace:on
# --debugger:native
cpDir("../libs/", "out/")
mkdir("out/assets")
cpDir("../assets", "out/assets")