import std/[times, os, tables, httpclient, asyncdispatch, strformat]

var httpClientGlobal*: AsyncHttpClient
var serverAddressGlobal*: string