import sys
mode = "Trainer" if len(sys.argv) == 1 else sys.argv[1]
comp = "Testor"
if mode != "Trainer" and mode != "Testor" and len(sys.argv) > 1:
    print(f"Mode passed as: {sys.argv[1]}")
    print("Mode can be either Trainer or Testor")
    sys.exit(0)
    
else:
    comp = "Testor" if mode == "Trainer" else "Trainer"

lines = []
with open('./pom.xml', 'r+') as f:
    lines = f.readlines()
    for i, line in enumerate(lines):
        if f"<artifactId>MLTrain_{comp}</artifactId>" in line:
            lines[i] = line.replace(comp, mode)
        if f"<scala.version>2.11</scala.version>" in line and mode == "Testor":
            lines[i] = line.replace("2.11", "2.12") 
        if f"<scala.version>2.12</scala.version>" in line and mode == "Trainer":
            lines[i] = line.replace("2.12", "2.11")
        if f"<spark.version>2.4.5</spark.version>" in line and mode == "Testor":
            lines[i] = line.replace("2.4.5", "3.3.1") 
        if f"<spark.version>3.3.1</spark.version>" in line and mode == "Trainer":
            lines[i] = line.replace("3.3.1", "2.4.5")
        if f"<mainClass>{comp}</mainClass>" in line:
            lines[i] = line.replace(comp, mode)
    
    f.writelines([])
    f.close()
with open('./pom.xml', 'w') as f:
    f.writelines(lines)
    f.close()
    