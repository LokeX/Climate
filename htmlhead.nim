const 
  startHTML* = """
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
      #textArea {
				padding: 1px 1px 1px 10px;
				width: 95%;
				border-style: inset;
				border: 3px groove;
				border-radius: 5px;
				border: 1px solid black;
				background-color: rgb(27, 27, 27);
				border-radius: 5px;
			}
		</style>
  </head>
  <body>
"""
  endHTML* = """
  </body>
</html>
"""
  startRssHTML* = """<div id="textArea">"""
  endRssHTML* = """</div>"""
