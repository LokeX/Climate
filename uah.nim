import httpclient,os,sequtils,strutils,times

type
  Dataset = enum lt,mt,tp,ls

const
  datasets:array[Dataset,tuple[setName,url:string]] = [
    ("Lower Troposphere","https://www.nsstc.uah.edu/data/msu/v6.1/tlt/uahncdc_lt_6.1.txt"),
    ("Middle Troposphere","https://www.nsstc.uah.edu/data/msu/v6.1/tmt/uahncdc_mt_6.1.txt"),
    ("TropoPause","https://www.nsstc.uah.edu/data/msu/v6.1/ttp/uahncdc_tp_6.1.txt"),
    ("Lower Stratosphere","https://www.nsstc.uah.edu/data/msu/v6.1/tls/uahncdc_ls_6.1.txt")
  ]

iterator toRows(dataLines:openArray[string]):string =
  var idx = 1
  while not dataLines[idx].startsWith " Year":
    yield dataLines[idx]
    inc idx

iterator mainLabels(labels:openArray[string]):string =
  for i in countup(2,labels.find("SoPol"),3):
    yield labels[i]

func getDataset(prm:string):Dataset =
  for i,data in Dataset.mapIt $it:
    if prm == data: return Dataset(i)

func indexLabel(labels:openArray[string],prm:string):int =
  result = labels.mapIt(it.toLower).find(prm)
  if result == -1: result = 2

func toDataPoint(dataPointRow:string,colIdx:int):string =
  let 
    items = dataPointRow.splitWhitespace
    dataPoint = try: items[colIdx].parseFloat except: -0.99
    month = try: items[1].parseInt except: -1
  result = items[0]&"-"&(if month != -1: ($Month(month))[0..2] else: "N/A")
  result.add dataPoint.formatFloat(ffDecimal,2).align 9

func landOceanAdj(prm:string):int =
  case prm
  of "land": 1
  of "ocean": 2
  else: 0

func makeLabel(labels:seq[string],labelIndex,columnIndex:int):string =
  result = labels[labelIndex]
  if columnIndex > labelIndex: result.add "/"&labels[columnIndex]

proc param(idx:int,def:string):string =
  if paramCount() >= idx: paramStr(idx).toLower else: def

let
  selectedDataset = getDataset param(1,"lt")
  datalines = newHttpClient().getContent(datasets[selectedDataset].url).splitLines
  labels = datalines[0].splitWhitespace

if paramCount() == 0:
  echo ""
  echo "1st parameter"
  echo "UAH datasets:" 
  echo ""
  for aSet in Dataset:
    echo "  ",$aSet," - ",datasets[aSet].setName
  echo ""
  echo "2nd parameter"
  echo "Region:"
  echo ""
  for label in labels.mainLabels:
    echo "  "&label
  echo ""
  echo "optional 3rd parameter:"
  echo "Region subset:" 
  echo ""
  echo "  Land"
  echo "  Ocean"
  echo ""
  echo "Lower letters allowed"
else:
  let
    labelIndex = labels.indexLabel param(2,"globe")
    columnIndex = labelIndex+landOceanAdj param(3,"")
    dataPointCol = dataLines.toRows.toSeq.mapIt(it.toDataPoint columnIndex).join "\n"
    header = 
      "UAH/"&
      datasets[selectedDataset].setName&"/"&
      labels.makeLabel(labelIndex,columnIndex)&"\n"
  echo dataPointCol
  echo header
  writeFile("uah.txt",header&dataPointCol)
  echo "wrote to file: uah.txt"

