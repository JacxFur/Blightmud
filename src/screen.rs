use crate::ansi::*;
use std::io::{stdout, Stdout, Write};
use termion::{
    raw::{IntoRawMode, RawTerminal},
    screen::AlternateScreen,
};

pub struct Screen {
    screen: AlternateScreen<RawTerminal<Stdout>>,
    width: u16,
    _height: u16,
    output_line: u16,
    prompt_line: u16,
}

impl Screen {
    pub fn new() -> Self {
        let screen = AlternateScreen::from(stdout().into_raw_mode().unwrap());
        let (width, height) = termion::terminal_size().unwrap();

        let output_line = height - 3;
        let prompt_line = height;

        Self {
            screen,
            width,
            _height: height,
            output_line,
            prompt_line,
        }
    }

    pub fn setup(&mut self) {
        self.reset();
        write!(
            self.screen,
            "{}{}",
            ScrollRegion(1, self.output_line),
            DisableOriginMode
        )
        .unwrap(); // Set scroll region, non origin mode
        write!(
            self.screen,
            "{}",
            termion::cursor::Goto(1, self.output_line + 1)
        )
        .unwrap();
        write!(self.screen, "{:_<1$}", "", self.width as usize).unwrap(); // Print separator
        self.screen.flush().unwrap();
    }

    pub fn reset(&mut self) {
        write!(self.screen, "{}{}", termion::clear::All, ResetScrollRegion).unwrap();
    }

    pub fn print_prompt(&mut self, prompt: &str, input: &str) {
        write!(
            self.screen,
            "{}{}{}{}",
            termion::cursor::Goto(1, self.prompt_line),
            termion::clear::AfterCursor,
            prompt,
            input,
        )
        .unwrap();
    }

    pub fn print_output(&mut self, output: &str) {
        write!(
            self.screen,
            "{}{}\r\n{}",
            termion::cursor::Goto(1, self.output_line),
            output,
            termion::cursor::Goto(1, self.prompt_line)
        )
        .unwrap();
    }

    pub fn flush(&mut self) {
        self.screen.flush().unwrap();
    }
}
