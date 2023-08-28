rmdir("out")
mkdir("out")
--outdir:"out/"
--threads:on 
--debugger:native
cpDir("../libs/", "out/")
mkdir("out/assets")
cpDir("../assets", "out/assets")