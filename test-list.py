import os, json, sys, getopt; 

fullCmdArguments = sys.argv

directory = './'

if fullCmdArguments.len > 0 
    directory = './'+fullCmdArguments[1]


print json.dumps(os.listdir(directory))
print '------'
dirstring = str(os.listdir(directory))
print dirstring.replace("'",'"');

print '-------------------------'

# print sys.argv[1]

argumentList = fullCmdArguments[1:]

unixOptions = "ho:v"
gnuOptions = ["help", "output=", "verbose"]

try:
    arguments, values = getopt.getopt(argumentList, unixOptions, gnuOptions)
except getopt.error as err:
    # output error, and return with an error code
    print (str(err))
    sys.exit(2)


for currentArgument, currentValue in arguments:
    if currentArgument in ("-v", "--verbose"):
        print ("enabling verbose mode")
    elif currentArgument in ("-h", "--help"):
        print ("displaying help")
    elif currentArgument in ("-o", "--output"):
        print (("enabling special output mode (%s)") % (currentValue))
