rmdir("out")
mkdir("out")
--outdir:"out/"
--threads:on 
cpDir("../libs/", "out/")
mkdir("out/assets")
cpDir("../assets", "out/assets")
--backend:cpp