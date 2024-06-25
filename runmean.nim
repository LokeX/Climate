import os,strutils,sequtils,math,algorithm

type 
  Data = tuple
    date:string
    value:float

iterator linesToData(fileName:string):Data =
  for line in fileName.lines:
    let s = line.splitWhitespace
    try:yield (s[0],s[1].parseFloat) 
    except:yield (line&" - running mean",0.0)

func runningMean(data:seq[Data],winSize:int):seq[float] =
  for i in countdown(data.high,winSize):
    result.add data[i-winSize..i].mapIt(it.value).sum / winSize.toFloat
  reverse result
  let mean = result.sum/result.len.toFloat
  result.mapIt it-mean

func fmtFloat(f:float):string = f.formatFloat(ffDecimal,2).align 9

let
  filename = paramStr(1)&".txt"
  window = try: parseInt paramStr(2) except:36
  data = toSeq filename.linesToData
  means = data.runningMean window
  newData = data[0].date&" - window: "&($window)&"\n"&zip(data[window..data.high],means)
    .mapIt(it[0].date&(it[1]).fmtFloat)
    .join "\n"

echo newData
writeFile("runmean.txt",newData)
echo "Wrote file: runmean.txt"
echo "Type: plot runmean"
