# 从pegasus拷贝游戏后，需要执行此脚本将Pegasus格式的列表改为RetroArch的，包括缩略图和ROM文件。

# ！！！需要提前把boxFront.jpg转换为boxFront.png

ROOT_PATH=$(git rev-parse --show-toplevel)
source "$ROOT_PATH/hack/config.sh"

read_pegasus_metadata() {
    while read -r line; do
        # 如果是空行，则表示要解析下一个文件了
        if [[ -z "$line" ]]; then
            # echo $rom_title $rom_name $rom_ext
            # 把英文名或者标号的rom文件改名为rom_title            
            if [[ -f "$emulator_roms_dir/$rom_file" ]] && [[ ! -z $rom_file ]]; then
                if [[ "$emulator_roms_dir/$rom_file" != "$emulator_roms_dir/$rom_title$rom_ext" ]]; then
                    mv "$emulator_roms_dir/$rom_file" "$emulator_roms_dir/$rom_title$rom_ext"
                    echo moving:$'\t' "$emulator_roms_dir/$rom_file" "$emulator_roms_dir/$rom_title$rom_ext"
                fi
            # 把包含子目录的文件夹按照title重新命名
            elif [[ -d "$emulator_roms_dir/$rom_file" ]]; then
                if [[ $emulator_roms_dir/$rom_file != "$emulator_roms_dir/$rom_title" ]] && [[ ! -z $rom_file ]]; then
                    mv "$emulator_roms_dir/$rom_file" "$emulator_roms_dir/$rom_title"
                    echo moving:$'\t' "$emulator_roms_dir/$rom_file" "$emulator_roms_dir/$rom_title"
                fi
            fi

            # 批量移动图片到RetroArch的目录格式
            if [[ -f "$emulator_roms_dir/media/$rom_name/boxFront.png" ]]; then
                mv "$emulator_roms_dir/media/$rom_name/boxFront.png" "$emulator_boxarts/$rom_title.png" 
                echo moving:$'\t' "$emulator_roms_dir/media/$rom_name/boxFront.png" "$emulator_boxarts/$rom_title.png" 
            fi

            # TODO: 确认没有问题后，就可以把media文件夹删除掉了，避免拷贝的时候浪费空间和时间。

            rom_tile=""
            rom_file=""
            rom_name=""
        # 提取游戏的名称，在RetroArch中，把游戏名、文件名、缩略图名都统一为这个
        elif [[ "$line" == game:* ]]; then
            # 删除第一个“: ”及前面的字符
            # 比如：幽游白书
            rom_title=${line#*:\ }
            # 替换/为-，防止有的名字中有斜杠
            rom_title=${rom_title//\//-}
        # 获取文件名称。
        elif [[ "$line" == file:* ]]; then
            # 比如：Yu Yu Hakusho (Japan).chd
            rom_file=${line#*:\ }
            # 比如：Yu Yu Hakusho (Japan)
            rom_name=${rom_file%.*}
            # 比如：.chd
            rom_ext=.${rom_file##*.}            
        # 获取文件名称。如果包含子文件夹，则需要提取文件夹
        elif [[ "$line" == files:* ]]; then
            # TODO: 如何处理一个游戏有多个文件？
            # echo "multiple files, skip"
            # !!!注意read line的时候会把space省略掉，这里要加上IFS=空
            discs=""
            while IFS= read -r line; do
                if [[ "$line" == " "* ]];then 
                    # echo "started with \s： $line"
                    # 比如：Yu Yu Hakusho (Japan)
                    rom_file=${line%%/*}
                    discs+=${line#*/}$'\n'
                    rom_file=${rom_file##*\ \ }
                else
                    if [[ -d  "$emulator_roms_dir/$rom_file" ]]; then
                        echo $discs > "$emulator_roms_dir/$rom_file/menu.m3u"
                    else
                        echo "$emulator_roms_dir/$rom_file" >> missing.txt
                    fi

                    break
                fi
            done
            # 比如：Yu Yu Hakusho (Japan)
            rom_name=$rom_file
            # 此处为文件夹，所以没有扩展名
            rom_ext=""   
        fi
    done <"$pg_matadata_file"
}


RA_BASE_DIR=./emulators/RetroArch/_base_/RetroArch
convert_all_emulators() {
    # ./emulators/RetroArch/_base_/RetroArch/@ROM/3DO
    for emulator in "${emulators[@]}"; do  
        emulator_roms_dir="$RA_BASE_DIR/@ROM/$emulator"
        emulator_name=$(basename $emulator_roms_dir)
        # ./emulators/RetroArch/_base_/RetroArch/thumbnails/3DO/Named_Boxarts
        emulator_boxarts=$RA_BASE_DIR/thumbnails/$emulator_name/Named_Boxarts
        # ./emulators/RetroArch/_base_/RetroArch/@ROM/metadata.pegasus.txt
        pg_matadata_file=$emulator_roms_dir/metadata.pegasus.txt

        echo start:$'\t' $emulator_name

        if [[ ! -d "$emulator_boxarts" ]]; then 
            mkdir -p "$emulator_boxarts"
        fi
        
        read_pegasus_metadata
    done
}


convert_all_emulators

