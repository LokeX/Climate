import httpclient,os,strutils,times

if paramCount() < 2:
  echo "usage:"
  echo "index [index name] [index url]"
  quit()

let
  data = newHttpClient().getContent paramStr(2)
  label = paramStr(1)
  filename = label.toLower&".txt"

echo data

var
  dataColumn:string

template fmtLine(s:untyped):untyped =
  s.parseFloat.formatFloat(ffDecimal,2).align 9

func toColumn(dataLine:seq[string]):string =
  for month in Month:
    let dataPoint = dataLine[month.ord]
    if not dataPoint.contains "99":
      result.add dataLine[0]&"-"&($month).substr(0,2)&dataPoint.fmtLine&"\n"

for line in data.splitLines:
  if (let words = line.splitWhitespace; words.len == 13): 
    try: discard line[0..3].strip.parseInt 
    except: continue
    dataColumn.add words.toColumn

writeFile(filename,label&"\n"&dataColumn)
echo "Wrote file: ",filename
echo "Type either:"
echo "  plotmean ",label
echo "  plot ",label

