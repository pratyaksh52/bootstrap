function realpath_compat
    if type -q realpath
        realpath $argv[1]
    else
        python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' $argv[1]
    end
end
