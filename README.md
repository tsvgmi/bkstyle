# NAME
    bkstyle - Tool to manage style/performance files for Roland BK-3

# SYNOPSIS
    bkstyle [global options] command [command options] [arguments...]

# VERSION
    0.0.1

# GLOBAL OPTIONS
    -f, --force    - Force mode. Overwrite if needed
    --help         - Show this message
    -n, --dryrun   - Test run only
    -o, --ofmt=arg - Output format (default: none)
    --version      - Display the program version

# COMMANDS
    folder - Manage Style Folder
    help   - Shows a list of commands or help for one command
    ups    - Manage Performance (UPS) File
    
 ---
 
## NAME
    folder - Manage Style Folder

## SYNOPSIS
    bkstyle [global options] folder midi_fix [-r|--recursive] [-t arg|--target arg] mode
    bkstyle [global options] folder split [-c|--copy] [-r|--recursive] [-t arg|--target arg] mode

## COMMANDS
    midi_fix - Source mode (ari, ari.n, cali, cali.n)
    split    - Source mode (ari, ari.n, cali, cali.n)
---

## NAME
    ups - Manage Performance (UPS) File

## SYNOPSIS
    bkstyle [global options] ups [command options] bedit edit_file
    bkstyle [global options] ups [command options] clone target_name
    bkstyle [global options] ups [command options] list file_name
    bkstyle [global options] ups [command options] rename [order.]new_name[, [order.]new_name]*

## COMMAND OPTIONS
    -o, --ofile=arg - Output File (default: none)

## COMMANDS
    bedit  -
    clone  -
    list   -
    rename -