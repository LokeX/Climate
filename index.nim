import httpclient,os,strutils,times

let
  data = newHttpClient().getContent paramStr(2)

var
  dataColumn:string

func fmtLine(s:string):string =
  s.parseFloat.formatFloat(ffDecimal,2).align 9

func toColumn(dataLine:seq[string]):string =
  for month in Month:
    let dataPoint = dataLine[month.ord]
    if not dataPoint.contains "99":
      result.add dataLine[0]&"-"&($month).substr(0,2)&dataPoint.fmtLine&"\n"

for line in data.splitLines:
  try:discard line[0..3].parseInt except:continue
  dataColumn.add line.splitWhitespace.toColumn

echo dataColumn
writeFile("index.txt",paramStr(1)&"\n"&dataColumn)
echo "Wrote file: index.txt"
echo "Type either:"
echo "  plotmean index"
echo "  plot index"

