package main

import std::io::{stdin, stdout}

enum TokenKind {
    Number(Float64),
    Plus,
    Minus,
    Mul,
    Div,
    LParen,
    RParen
}

fn tokenize(input: String) -> Result<Array<TokenKind>, String> {
    let mut tokens = Array<TokenKind>::new()
    let mut index: Int64 = 0
    let chars = input.chars().collect_array()
    let length = chars.size()

    while index < length {
        let ch = chars[index]
        if ch.is_whitespace() {
            index += 1
            continue
        }

        if (ch >= '0' && ch <= '9') || ch == '.' {
            let mut numText = String::new()
            while index < length && ((chars[index] >= '0' && chars[index] <= '9') || chars[index] == '.') {
                numText.push(chars[index])
                index += 1
            }
            match Float64::parse(numText) {
                Ok(val) => tokens.append(TokenKind::Number(val)),
                Err(_) => return Err("数字解析失败：".concat(numText))
            }
            continue
        }

        match ch {
            '+' => { tokens.append(TokenKind::Plus); index += 1 }
            '-' => { tokens.append(TokenKind::Minus); index += 1 }
            '*' => { tokens.append(TokenKind::Mul); index += 1 }
            '/' => { tokens.append(TokenKind::Div); index += 1 }
            '(' => { tokens.append(TokenKind::LParen); index += 1 }
            ')' => { tokens.append(TokenKind::RParen); index += 1 }
            _ => return Err(format!("非法字符：'{}'", ch))
        }
    }
    Ok(tokens)
}

struct Parser {
    tokens: Array<TokenKind>,
    pos: Int64
}

impl Parser {
    fn new(tokens: Array<TokenKind>) -> Self {
        Parser { tokens: tokens, pos: 0 }
    }

    fn peek(&self) -> Option<&TokenKind> {
        if self.pos < self.tokens.size() {
            Some(&self.tokens[self.pos])
        } else {
            None
        }
    }

    fn advance(&mut self) {
        self.pos += 1
    }

    fn parse_expr(&mut self) -> Result<Float64, String> {
        let mut value = self.parse_term()?
        loop {
            match self.peek() {
                Some(TokenKind::Plus) => {
                    self.advance()
                    let t = self.parse_term()?
                    value += t
                }
                Some(TokenKind::Minus) => {
                    self.advance()
                    let t = self.parse_term()?
                    value -= t
                }
                _ => break
            }
        }
        Ok(value)
    }

    fn parse_term(&mut self) -> Result<Float64, String> {
        let mut value = self.parse_factor()?
        loop {
            match self.peek() {
                Some(TokenKind::Mul) => {
                    self.advance()
                    let f = self.parse_factor()?
                    value *= f
                }
                Some(TokenKind::Div) => {
                    self.advance()
                    let f = self.parse_factor()?
                    if f == 0.0 {
                        return Err("运行错误：除零不允许")
                    }
                    value /= f
                }
                _ => break
            }
        }
        Ok(value)
    }

    fn parse_factor(&mut self) -> Result<Float64, String> {
        match self.peek() {
            Some(TokenKind::Number(n)) => {
                let num = *n
                self.advance()
                Ok(num)
            }
            Some(TokenKind::Minus) => {
                self.advance()
                let subVal = self.parse_factor()?
                Ok(-subVal)
            }
            Some(TokenKind::LParen) => {
                self.advance()
                let innerExpr = self.parse_expr()?
                match self.peek() {
                    Some(TokenKind::RParen) => self.advance(),
                    _ => return Err("语法错误：括号不匹配，缺少 ')'")
                }
                Ok(innerExpr)
            }
            _ => Err("语法错误：表达式不完整")
        }
    }

    fn parse_full(&mut self) -> Result<Float64, String> {
        let res = self.parse_expr()?
        if self.pos < self.tokens.size() {
            return Err("语法错误：表达式末尾存在多余符号")
        }
        Ok(res)
    }
}

fn calculate_expression(expr: String) -> Result<Float64, String> {
    let tokens = tokenize(expr)?
    let mut parser = Parser::new(tokens)
    parser.parse_full()
}

fn main() {
    stdout().write_line("======== 仓颉控制台计算器 ========").unwrap()
    stdout().write_line("输入算式进行计算，输入 q 退出程序").unwrap()

    loop {
        stdout().write(">>> ").unwrap()
        let inputResult = stdin().read_line()
        match inputResult {
            Ok(rawLine) => {
                let line = rawLine.trim()
                if line == "q" || line == "Q" {
                    stdout().write_line("程序退出").unwrap()
                    break
                }
                if line.is_empty() {
                    continue
                }
                match calculate_expression(line.to_string()) {
                    Ok(resultNum) => stdout().write_line(format!("结果 = {}", resultNum)).unwrap(),
                    Err(errMsg) => stdout().write_line(format!("错误：{}", errMsg)).unwrap()
                }
            }
            Err(_) => {
                stdout().write_line("读取输入失败，程序退出").unwrap()
                break
            }
        }
    }
}
