# 基于仓颉语言的算术表达式计算器
西安交通大学《仓颉语言程序设计》课程项目，第34组

## 项目简介
本项目实现一个控制台算术表达式计算器，采用递归下降分析法，支持四则运算、括号、小数与负数，包含异常处理。

## 文件结构
src/
└── main.cj
## 编译与运行
```bash
cjc src/main.cj -o calculator
./calculator
输入 q 退出程序。

功能列表

• 加减乘除运算，遵循运算优先级

• 支持圆括号嵌套

• 支持小数、负数

• 非法字符、除零、括号不匹配等错误捕获

小组成员

Zhanybek Shalpekov
Meghaouri Abderrahim
陈策
