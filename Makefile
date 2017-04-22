http://blog.csdn.net/ruglcc/article/details/7814546/#t3
	
一、初步认识
Makefile 定制整个工程的编译规则，像shell一样，也能执行操作系统：

objects = foo.o bar.o 
   all: $(objects)
   $(objects): %.o: %.c
           $(CC) -c $(CFLAGS) $< -o $@

	上面的例子中，指明了我们的目标从$object中获取，“%.o”表明要所有以“.o”结尾的目标，也就是“foo.o bar.o”，
	也就是变量$object集合的模式，而依赖模式“%.c”则取模式“%.o”的“%”，也就是“foobar”，并为其加下“.c”的后
	缀，于是，我们的依赖目标就是“foo.cbar.c”。而命令中的“$<”和“$@”则是自动化变量，“$<”表示所有的依赖目标
	集（也就是“foo.c bar.c”），“$@”表示目标集（也就是foo.o bar.o”）。


 files = foo.elc bar.o lose.o
 	$(filter %.o,$(files)): %.o: %.c
			$(CC) -c $(CFLAGS) $< -o $@
	$(filter %.elc,$(files)): %.elc: %.el
           emacs -f batch-byte-compile $<
	
	$(filter%.o,$(files))表示调用Makefile的filter函数，过滤“$filter”集，只要其中模式为“%.o”的内容。


 -rm -f *.o”  
 	忽略命令执行返回状态，当命令执行出错时，make继续解释Makefile规则
 @echo hello world
 	忽略命令本身，只在终端显示命令的执行结果，即在终端不会显示@echo hello world，只会显示hello world



二、变量
 x = $(y) 	  y = 2 	"="这种定义变量方式，变量可以先使用后定义
 y := 2 	  x = $(y) 	":="这种定义变量方式，变量必须先定义后使用（推荐）


 FOO ?= bar 	等价于 ifeq ($(origin FOO), undefined)
			FOO = bar
		      endif


$(var:a=b)”或是“${var:a=b}”，其意思是，把变量“var”中所有以“a”字串“结尾”的“a”替换成“b”字串 
实例 : foo := a.o b.o c.o 		foo := a.o b.o c.o
      bar := $(foo:.o=.c)	  	  bar := $(foo:%.o=%.c)


把变量的值再当成变量:x = y
		  y = z
		  a := $($(x))   此时a ＝ z
x = $(y)
y = z
z = Hello
a := $($(x)) 	这里的$($(x))被替换成了$($(y))，因为$(y)值是“z”，所以，最终结果是：a:=$(z)，也就是“Hello”。


a_objects := a.o b.o c.o
1_objects := 1.o 2.o 3.o
sources := $($(a1)_objects:.o=.c)
这个例子中，如果$(a1)的值是“a”的话，那么，$(sources)的值就是“a.c b.c c.c”；如果$(a1)的值是“1”，那么$(sources)的值是“1.c 2.c 3.c”。


prog : CFLAGS = -g 	为某个目标设定局部变量，它的作用范围只在这条规则以及连带（依赖）规则中


三、逻辑与内置函数
ifeq  ifneq  ifdef  ifndef  (以endif结尾)

3.1  字符串操作函数
$(subst <from>,<to>,<text> ) 字符替换函数

$(patsubst <pattern>,<replacement>,<text> ) 模式字符串（正则）替换函数与“$(var:<pattern>=<replacement> )” 相似

$(strip <string> ) 去字符串头尾空格函数——strip。

$(findstring <find>,<in> ) 查找字符串函数——findstring。

$(filter <pattern...>,<text> ) 以<pattern>模式过滤<text>字符串中的单词，保留符合模式<pattern>的单词（反过滤函数——filter-out）

$(sort <list> ) 给字符串<list>中的单词排序（升序）

$(word <n>,<text> ) 取字符串<text>中第<n>个单词。（从一开始）
	－－$(wordlist <s>,<e>,<text> ) 从字符串<text>中取从<s>开始到<e>的单词串。<s>和<e>是一个数字。
	－－$(words <text> ) 统计<text>中字符串中的单词个数。
	－－$(firstword <text> ) 取字符串<text>中的第一个单词。


3.2  文件名操作函数  
$(dir <names...> ) 文件名序列<names>中取出目录部分  示例： $(dir src/foo.c hacks)返回值是“src/ ./” （notdir）

$(suffix <names...> ) 返回文件名序列<names>的后缀序列 示例：$(suffix src/foo.c src-1.0/bar.c hacks)返回值是“.c .c”
	－－取前缀函数——basename  示例：$(basename src/foo.c src-1.0/bar.c hacks)返回值是“src/foo src-1.0/bar hacks”
	－－$(addsuffix <suffix>,<names...> ) 把后缀<suffix>加到<names>中的每个单词后面。
	－－$(addprefix <prefix>,<names...> ) 把前缀<prefix>加到<names>中的每个单词后面。

$(join <list1>,<list2> ) 把<list2>中的单词对应地加到<list1>的单词后面 （如果<list1>的单词个数要比<
						list2>的多，那么，<list1>中的多出来的单词将保持原样。如果<list2>的单词个数要比
						<list1>多，那么，<list2>多出来的单词将被复制到<list2>中）


3.3  foreach 函数
$(foreach <var>,<list>,<text> )
	－－把参数<list>中的单词逐一取出放到参数<var>所指定的变量中，然后再执行<text>所包含的表达式。每一次<text>会返回一个字符串，
		循环过程中，<text>的所返回的每个字符串会以空格分隔，最后当整个循环结束时，<text>所返回的每个字符串所组成的整个字符串（以
		空格分隔）将会是foreach函数的返回值

	names := a b c d
	files := $(foreach n,$(names),$(n).o)


3.4  if 函数
$(if <condition>,<then-part>,<else-part> )
	－－if函数可以包含“else”部分，或是不含。即if函数的参数可以是两个，也可以是三个。<condition>参数是if的表达式，如果其返回的为
		非空字符串，那么这个表达式就相当于返回真，于是，<then-part>会被计算，否则<else-part> 会被计算。
$(if <condition>,<then-part>,<else-part> )


3.5 call 函数
$(call <expression>,<parm1>,<parm2>,<parm3>...)
	－－<expression>参数中的变量，如$(1)，$(2)，$(3)等，会被参数<parm1>，<parm2>，<parm3>依次取代。而<expression>的返回值
		就是 call函数的返回值  例如：reverse = $(1) $(2)
					 foo = $(call reverse,a,b)


3.6 shell 函数
contents := $(shell cat foo)
	－－它和反引号“`”是相同的功能。这就是说，shell函数把执行操作系统命令后的输出作为函数（影响性能，建议不用）


四、隐含规则
定义在目标.SUFFIXES的依赖目标），那么隐含规则就会生效。默认的后缀列表是：.out,.a, .ln, .o, .c, .cc, .C, .....

$@
表示规则中的目标文件集。在模式规则中，如果有多个目标，那么，"$@"就是匹配于目标中模式定义的集合

$%
仅当目标是函数库文件中，表示规则中的目标成员名。例如，如果一个目标是"foo.a(bar.o)"，那么，"$%"就是"bar.o"，"$@"就是"foo.a"。
如果目标不是函数库文件（Unix下是[.a]，Windows下是[.lib]），那么，其值为空。

$<
依赖目标中的第一个目标名字。如果依赖目标是以模式（即"%"）定义的，那么"$<"将是符合模式的一系列的文件集。注意，其是一个一个取出来的。

$^
所有的依赖目标的集合。以空格分隔。如果在依赖目标中有多个重复的，那个这个变量会去除重复的依赖目标，只保留一份

$+
这个变量很像"$^"，也是所有依赖目标的集合。只是它不去除重复的依赖目标。

$*
这个变量表示目标模式中"%"及其之前的部分。如果目标是"dir/a.foo.b"，并且目标的模式是"a.%.b"，那么，"$*"的值就是"dir /a.foo"。这个变量对于构造有关联的文件名是比
较有较。如果目标中没有模式的定义，那么"$*"也就不能被推导出，但是，如果目标文件的后缀是 make所识别的，那么"$*"就是除了后缀的那一部分。例如：如果目标是"foo.c"
，因为".c"是make所能识别的后缀名，所以，"$*"的值就是"foo"。这个特性是GNU make的，很有可能不兼容于其它版本的make，所以，你应该尽量避免使用"$*"，除非是在隐含规则
或是静态模式中。如果目标中的后缀是make所不能识别的，那么"$*"就是空值。

对于上面的变量分别加上"D"或是"F"的含义：
	－－D：目录部分 $(@D)－表示"$@"的目录部分（不以斜杠作为结尾），如果"$@"值是"dir/foo.o"，那么"$(@D)"就是"dir"，而如果"$@"中没有包含斜杠的话，其值就是"."
	－－F：文件部分 $(@F)－表示"$@"的文件部分，如果"$@"值是"dir/foo.o"，那么"$(@F)"就是"foo.o"，"$(@F)"相当于函数"$(notdir $@)"。



五、使用make更新函数库文件
函数库文件也就是对Object文件（程序编译的中间文件）的打包文件。在Unix下，一般是由命令"ar"来完成打包工作。
archive(member)


这个不是一个命令，而一个目标和依赖的定义。一般来说，这种用法基本上就是为了"ar"命令来服务的。如：

foolib(hack.o) : hack.o
ar cr foolib hack.o
