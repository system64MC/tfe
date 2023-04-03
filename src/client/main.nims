mkdir("../../out/client")

if defined(win64):
  --os:windows

  rmdir("../../out/client")
  mkdir("../../out/client")
  --outdir:"../../out/client"
  --threads:on 
  --d:nimDontSetUtf8CodePage
  cpDir("lib", "../../out/client")
  mkdir("../../out/client/assets")
  cpDir("assets", "../../out/client/assets")