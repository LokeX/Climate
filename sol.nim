import httpClient
import times
import strutils
import math
import sequtils

type
  Item = tuple
    year:string
    month:Month
    kpAvg,kpNorm,apAvg,apNorm:float

const
  url = "https://kp.gfz-potsdam.de/app/files/Kp_ap_since_1932.txt"

echo "Downloading from:"
echo url

let 
  data = newHttpClient().getContent url

var
  items:seq[Item]
  currentMonth = -1
  currentYear = ""
  kps:seq[float]
  aps:seq[float]

for line in data.splitLines:
  try:
    if line.len > 0 and line[0] != '#':
      let 
        columns = line.splitWhitespace
        month = columns[1].parseInt
      kps.add columns[^3].parseFloat
      aps.add columns[^2].parseFloat
      if columns[0] != currentYear:
        currentYear = columns[0]
        echo ""
        echo "parsing year: ",currentYear
      if month != currentMonth:
        currentMonth = month
        items.add (
          currentYear,
          Month(currentMonth),
          kps.sum/kps.len.toFloat,
          0.0,
          aps.sum/aps.len.toFloat,
          0.0,
        )
        echo ($items[^1].month).align(12),
          ": (kp) ",
          items[^1].kpAvg.formatFloat(ffDecimal,2),
          " / (ap) ",
          items[^1].apAvg.formatFloat(ffDecimal,2)
        kps.setLen 0
        aps.setLen 0
  except: discard

template fmtAlign(f:untyped):untyped =
  f.formatFloat(ffDecimal,2).align(9)

template toDate(item:Item):untyped = 
  item.year&"-"&($item.month).substr(0,2)

func cline(items:seq[float]):seq[float] =
  let avg = items.sum/(float)items.len
  var accum:float
  for item in items:
    accum += item-avg
    result.add accum

echo ""
echo "Normalizing on period: ",items[0].year," - ",items[^1].year

let
  kpMean = items.mapIt(it.kpAvg).sum/items.len.toFloat
  apMean = items.mapIt(it.apAvg).sum/items.len.toFloat

for item in items.mitems:
  item.kpNorm = item.kpAvg-kpMean
  item.apNorm = item.apAvg-apMean

proc writeMsg(s:string) =
  echo ""
  echo "Wrote file: ",s,".txt"
  echo "Type: "
  echo "plot ",s
  echo "plotmean ",s

writeFile(
  "kp.txt",
  "Kp index\n"&
  items
  .mapIt(it.toDate&it.kpNorm.fmtAlign)
  .join "\n"
)
writeMsg "kp"
writeFile(
  "ap.txt",
  "Ap index\n"&
  items
  .mapIt(it.toDate&it.apNorm.fmtAlign)
  .join "\n"
)
writeMsg "ap"
writeMsg "kpminmax"
writeFile(
  "kpcline.txt",
  "Kp clines from mean\n"&
  zip(items,items.mapIt(it.kpAvg).cline).mapIt(it[0].toDate&it[1].fmtAlign).join "\n"
)
writeMsg "kpcline"
writeFile(
  "apcline.txt",
  "Ap clines from mean\n"&
  zip(items,items.mapIt(it.apAvg).cline).mapIt(it[0].toDate&it[1].fmtAlign).join "\n"
)
writeMsg "apcline"
