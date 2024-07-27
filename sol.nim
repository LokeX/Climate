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
    kpMax:float

const
  url = "https://kp.gfz-potsdam.de/app/files/Kp_ap_since_1932.txt"

echo "Downloading from:"
echo url

let 
  data = newHttpClient().getContent url

var
  items:seq[Item]
  currentMonth:Month = Month(1)
  currentYear = "1932"
  kps:seq[float]
  aps:seq[int]

for line in data.splitLines:
  try:
    if line[0] != '#':
      let 
        words = line.splitWhitespace
        month = Month(words[1].parseInt)
        kp = words[^3].parseFloat
        ap = words[^2].parseInt
      if month != currentMonth:
        items.add (
          currentYear,
          currentMonth,
          kps.sum/kps.len.toFloat,
          0.0,
          aps.sum.toFloat/aps.len.toFloat,
          0.0,
          kps.max,
        )
        kps.setLen 0
        aps.setLen 0
        currentMonth = month
        if words[0] != currentYear:
          currentYear = words[0]
        # echo items[^1]
      kps.add kp
      aps.add ap
  except:discard

template fmtAlign(f:untyped):untyped =
  f.formatFloat(ffDecimal,2).align(9)

func kpCline(items:seq[Item]):seq[float] =
  let avg = items.mapIt(it.kpAvg).sum/(float)items.len
  var accum:float
  for item in items:
    accum += item.kpAvg-avg
    result.add accum

template toDate(item:Item):untyped = 
  item.year&"-"&($item.month).substr(0,2)

let
  kpMean = items.mapIt(it.kpAvg).sum/items.len.toFloat
  apMean = items.mapIt(it.apAvg).sum/items.len.toFloat

for item in items.mitems:
  # echo item.kpNorm
  item.kpNorm = item.kpAvg-kpMean
  # echo item.kpNorm
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
writeFile(
  "kpminmax.txt",
  "Kp monthly max disturbance\n"&
  items
  .mapIt(it.toDate&it.kpMax.fmtAlign)
  .join "\n"
)
writeMsg "kpminmax"
writeFile(
  "kpcline.txt",
  "Kp clines from mean\n"&
  zip(items,items.kpCline).mapIt(it[0].toDate&it[1].fmtAlign).join "\n"
)
writeMsg "kpcline"
