from sequtils import zip
import strutils

type Designation = enum neutral,laNina,elNino

template ninoSignal(value:float):int =
  if value >= 0.5: 1 elif value <= -0.5: -1 else: 0

template carrySignal(oldSignal,newSignal:int):int =
  if newSignal == 0 or oldSignal*newSignal < 0: newSignal 
  else: oldSignal+newSignal

func ninoSignals(values:openArray[float]):seq[int] =
  result.add carrySignal(0,values[0].ninoSignal)
  for value in values[1..values.high]: 
    result.add carrySignal(result[^1],value.ninoSignal)

iterator reversed[T](x:openArray[T]):(int,T) =
  var idx = x.high
  while idx >= x.low:
    yield (idx,x[idx])
    dec idx

func ninoDesignations(signals:openArray[int]):seq[Designation] =
  result.setLen signals.len
  for i,signal in signals.reversed: 
    result[i] = 
      if signal <= -5: 
        laNina
      elif signal >= 5: 
        elNino
      elif signal == 0 or i == signals.high: 
        neutral
      else: 
        result[i+1] 

func parse(lines:openArray[string]):(string,seq[string],seq[float]) =
  result[0] = lines[0]&"\n"&lines[1]
  for line in lines[2..lines.high]:
    result[1].add line[0..3]
    for valStr in line[4..line.high].splitWhitespace: 
      result[2].add valStr.parseFloat

func monthsOf[T](months:openArray[T],indexYear:int):seq[T] =
  let 
    startMonth = indexYear*12
    endMonth = if startMonth+11 > months.high: months.high else: startMonth+11
  months[startMonth..endMonth]

let 
  (labels,years,values) = parse readFile("nina34matrix.txt").splitLines
  monthlyData = zip(values,values.ninoSignals.ninoDesignations)

from terminal import ForegroundColor,styledWrite

template fgColor(designation:Designation):ForegroundColor =
  case designation:
    of elNino: fgRed
    of laNina: fgBlue
    of neutral: fgWhite

template htmlColor(designation:Designation):string =
  case designation:
    of elNino: "style=\"color:red;\""
    of laNina: "style=\"color:dodgerblue;\""
    of neutral: "style=\"color:green;\""

func headerRow(cells:seq[string]):string =
  result.add "\t\t\t<tr>\n"
  for i,cell in cells:
    if i == 0: result.add "\t\t\t\t<th>&nbsp</th>\n"
    result.add "\t\t\t\t<th>"&cell&"</th>\n"
  result.add "\t\t\t</tr>\n"

const 
  startHTML = """
<!DOCTYPE html>
<html>
  <head>
		<meta charset="utf8">
		<meta name="viewport" content="width=device-width">
		<style type="text/css">
			body {
				background-color: #1B0C0C;
			}
			td {
				text-align:right;
			}
			th {
				width:7%;
				color:white;
			}
		</style>
  </head>
  <body>
"""
  endHTML = """
  </body>
</html>
"""

let 
  htmlFile = open("nino.html",fmWrite)

htmlFile.write startHTML
htmlFile.write "\t\t<table>\n"
htmlFile.write headerRow labels.splitLines[1].splitWhitespace
stdout.write labels
for indexYear,year in years:
  htmlFile.write "\t\t\t<tr>\n"
  htmlFile.write "\t\t\t\t<td style=\"color:white;\">"&year&"\n"
  stdout.write "\n"&year
  for (value,ninoDesignation) in monthlyData.monthsOf indexYear:
    let val = value.formatFloat(ffDecimal,4)
    stdout.styledWrite ninoDesignation.fgColor,val.align 9
    htmlFile.write "\t\t\t\t<td "&ninoDesignation.htmlColor&">"&val&"</td>\n"
  htmlFile.write "\t\t\t</tr>\n"
htmlFile.write "\t\t</table>\n"
htmlFile.write endHTML
htmlFile.close
echo "\n\nType:"
echo "nino.html"
echo "- to view in browser"
