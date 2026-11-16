import sys, xml.etree.ElementTree as ET
for n in ET.parse(sys.argv[1]).getroot().iter("node"):
    if n.get("focused") == "true":
        t = [d.get("text") for d in n.iter("node") if d.get("text")]
        print(t[0] if t else ""); break
else:
    print("")
