#!/bin/bash
git diff $1 $2 --name-status|awk '{if($1!="D") print $2>"add_init.txt"}'
git diff $1 $2 --name-status|awk '{if($1=="D") print $2>"del_init.txt"}'
#对del_init.txt文件路径进行处理
if test -f "del_init.txt"
then
grep 'SimplifiedChineseRes' del_init.txt>del_init_grep.txt
fi
if test -f "del_init_grep.txt"
then
cut -d '/' -f 3- del_init_grep.txt  >del.txt
fi
grep 'SimplifiedChineseRes' add_init.txt >add_init_grep.txt
cut -d '/' -f 3- add_init_grep.txt >add.txt
#把每个文件压缩到dhljupdate_enc.zip,这个步骤主要为了新建一份有相同目录的拷贝，进行加密
echo "第一次压缩:把需要处理的资源文件进行压缩:"
while read zipfileenc
do
  zip dhljupdate_enc.zip $zipfileenc
done<add.txt
echo "第一次压缩结束"
#把dhljupdate_enc.zip进行解压到UPDATE_DIR目录
echo "把资源包解压到update_dir目录下统一处理:"
unzip -d ./update_dir/ dhljupdate_enc.zip
echo "解压到update_dir成功"
cp add.txt update_dir/
if test -f "del.txt"
then
cp del.txt update_dir/
fi
grep -i '\.lua$' add.txt|sed -e "s/SimplifiedChineseRes/update_dir\/SimplifiedChineseRes/g" >add_grep_lua.txt
#过滤DBData文件夹的数据，这部分文件不进行加密
grep -i '\.ini$' add.txt|sed -e "s/SimplifiedChineseRes/update_dir\/SimplifiedChineseRes/g"|grep -v "/DBData"|grep -v "version.ini" >add_grep_ini.txt
grep -i '\.png$' add.txt|sed -e "s/SimplifiedChineseRes/update_dir\/SimplifiedChineseRes/g" >add_grep_png.txt
echo "开始编译lua文件:"
if test -f "add_grep_lua.txt"
then
while read LuaFile
do
echo $LuaFile>LuaFile.txt
target=`sed -e "s/.lua/.bin/g" LuaFile.txt`
luac -o $target $LuaFile
echo $target>>add_grep_lua_bin.txt
done<add_grep_lua.txt
fi
echo "编译lua文件结束"
echo "开始lua,ini加密:"
./EncryptLua
echo "加密lua,ini结束"
echo "开始png加密:"
./EncryptPng
echo "加密png结束"
cd update_dir
#需要打包到更新包的是bin文件，而不是lua本身文件
sed -e "s/.lua/.bin/g" add.txt>add_bin.txt
echo "开始压缩最终的更新包:"
while read zipfile
do
  zip dhljupdate.zip $zipfile
done<add_bin.txt
if test -f "del.txt"
then
zip dhljupdate.zip del.txt
fi
echo "更新包压缩结束"
#确保删除临时文件
#rm *.txt
#rm *.zip
