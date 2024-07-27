import strutils,httpClient,sugar
from times import Month

const
  url = "https://data.longpaddock.qld.gov.au/SeasonalClimateOutlook/SouthernOscillationIndex/SOIDataFiles/MonthlySOIPhase1887-1989Base.txt"

func parseEntries(dataLines:seq[string]):string =
  for line in dataLines:
    if line.len > 0:
      let words = line.splitWhitespace
      let (year,month,value) = (
        words[0],
        Month(words[1].parseInt),
        words[2].parseFloat
      )
      result.add year&"-"&($month)[0..2]&
        value.formatFloat(ffDecimal,2).align(9)&"\n"

let
  content = newHttpClient().getContent url
  contentLines = content.splitLines
  dataLines = contentLines[1..contentLines.high]
  entries = dataLines.parseEntries
  title = contentLines[0].splitWhitespace[2]

echo title
echo entries
writeFile("soi.txt",title&"\n"&entries)
echo "wrote file: soi.txt"
echo "type: "
echo "plot soi"
echo "plotmean soi"

