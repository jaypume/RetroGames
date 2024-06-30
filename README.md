# RetroGames



## 这个可以干什么

- 管理跨平台的怀旧游戏。运行平台包括：    
    - Android
    - Apple IOS
    - Nintendo Switch
    - Sony PSV
    - Windows
- 添加游戏后，脚本自动更新游戏列表和缩略图。
- 基于git-lfs实现同一份ROM只保留单份拷贝。
- Switch自动更新拼音目录（因为Switch不支持中文名怀旧游戏文件）

## 为什么要做这个？
- 管理混乱，当前怀旧游戏ROM的管理混乱，没有版本的概念，尤其是中文游戏ROM。
- 无法协作，不同的怀旧游戏爱好者维护着自己的列表，每个人维护的游戏都不全。
- 浪费空间，重复的ROM文件存储浪费空间
- 无法跨平台，比如我希望在Switch、IOS上等各个平台玩耍，ROM文件、缩略图、列表的迁移都需要大量工作。



## update 2024.07.01
为什么暂停 git lfs的维护？原因有2点
后续如果git lfs能优化这两点的话，那么可以迁移到lfs
1. git lfs pull 后，本地会占用2份拷贝。磁盘空间利用率低
```
i@PLUS-1215U MINGW64 /h/RetroGames (main)
$ du -hd1
27G     ./.git
28G     ./emulators
4.0K    ./environment
1.9M    ./hack
55G     .
```


2. git lfs pull 读写速率不能达到满速
* 实测SSD ：       Downloading LFS objects: 100% (6507/6507), 29 GB | 44 MB/s
* 实测三星512G白卡：Downloading LFS objects:  14% (899/6507), 3.7 GB | 4.6 MB/s


对于文件数量巨大的，git clone也需要花上约17分钟。
```
$ date && GIT_LFS_SKIP_SMUDGE=1 git clone https://github.com/jaypume/RetroGames.git
2024年07月 1日  0:36:39
Cloning into 'RetroGames'...
remote: Enumerating objects: 18848, done.
remote: Counting objects: 100% (18848/18848), done.
remote: Compressing objects: 100% (18490/18490), done.
remote: Total 18848 (delta 215), reused 18808 (delta 178), pack-reused 0
Receiving objects: 100% (18848/18848), 12.15 MiB | 1.59 MiB/s, done.
Resolving deltas: 100% (215/215), done.
Updating files: 100% (18383/18383), done.

i@PLUS-1215U MINGW64 /f
$ date
2024年07月 1日  0:53:29
```


相比git annex的优势：
* 不依赖于symlink，跨平台支持（windows / linux / mac）
* github等平台集成
* 利用文件的hash，能有效去重（git annex 有待确认？）


## 使用教程
如果你仅仅需要拷贝游戏到自己的游戏平台上的话。

0. 安装模拟器 
可以去如下地址寻找对应平台的RetroArch模拟器
```
https://buildbot.libretro.com/stable/
```

1. 下载游戏包，解压到'.git/lfs'

2. 启动lfs-testing-server

参考这里：
https://github.com/git-lfs/lfs-test-server

run.sh脚本如下：

```
#!/bin/bash

set -eu
set -o pipefail

LFS_LISTEN="tcp://:9999"
LFS_HOST="127.0.0.1:9999"
LFS_CONTENTPATH="content"
LFS_ADMINUSER="admin"
LFS_ADMINPASS="admin"
LFS_CERT="mine.crt"
LFS_KEY="mine.key"
LFS_SCHEME="https"

export LFS_LISTEN LFS_HOST LFS_CONTENTPATH LFS_ADMINUSER LFS_ADMINPASS LFS_CERT LFS_KEY LFS_SCHEME

#lfs-test-server.exe
 /c/Users/i/go/bin/lfs-test-server.exe
```

3. 配置需要下载的路径
```
git config http.sslverify false
git config lfs.fetchinclude "$(paste -sd ',' emulators/RetroArch/romlist/G030.txt)"
git config lfs.fetchinclude "$(paste -sd ',' rom.txt)"
```
4. pull
```
git lfs pull
```

## 可以实现什么样的效果？(TODO)
### Windows
### Nintendo Switch
### Sony PSV
### Apple IOS
### Android


## 更新游戏教程
如果你需要自行添加游戏ROM并更新列表的话。
### 新ROM增加或改名后怎么办？
比如如果更新了PSP文件名和缩略图文件名的话：
1. 删除CSV中的PSP.csv
2. 执行 `zsh hack/update-playlists.sh`

### 如果更新了Switch咋办？
1. `bash hack/update-switch.sh`

## 待办

<!-- [-] 在-和·前后添加空格， -->
- [x] GBA几个文件改名
- [x] 自动更新Switch ROM文件夹（如果改名了的话）
- [x] 不用保留unsorted的csv

- [x] 增加Switch列表，
- [ ] CSV英文中有逗号... 待修改分隔符
- [ ] 封面中的中文改怎么修改？
- [ ] .Test合集等自动化
- [ ] NeoGeo改成咸鱼的ROM
      rom/Sega/1988 - MD/_source/MD.老街巷子游戏厅_咸鱼
- [ ] 清理: N64咸鱼文件夹，因为里面有很多cmd等文件。
- [ ] 编写天马 -> RA格式的转换
    - Nintendo - N64
    - Nintendo - NDS
    - Sega - Naomi
    - Sega - Saturn
    - SNK - NGPC

- [ ] 思考文件夹类型的rom
    - 中文名/xx.cue,xx.bin
    - 中文名/xxx.zip
    - 中文名/xxx.zip 一堆系列的，NEOGEO，要改成咸鱼

- [ ] 增加RetroArch每种平台的图标
- [ ] 优化cp命令
    - 图形界面
    - 展示拷贝进度条。
- [ ] 添加retroarch.cfg版本管理
- [ ] 添加存档同步方案/saves/states
