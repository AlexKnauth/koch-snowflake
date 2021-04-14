extern crate image;
extern crate imageproc;

use image::{Rgb, RgbImage};
use imageproc::drawing::draw_antialiased_line_segment_mut;
use imageproc::pixelops::interpolate;

type Pos = (f32, f32);
type Color = Rgb<u8>;

const DEFAULT_LINE_CUTOFF: f32 = 4f32;
const TAU_OVER_6: f32 = std::f32::consts::FRAC_PI_3;
const WHITE: Color = Rgb([255u8, 255u8, 255u8]);
const BLACK: Color = Rgb([0u8, 0u8, 0u8]);

fn sqr(a: f32) -> f32 { a * a }
fn pos_plus(a: Pos, b: Pos) -> Pos { (a.0 + b.0, a.1 + b.1) }
fn pos_delta(a: Pos, b: Pos) -> Pos { (b.0 - a.0, b.1 - a.1) }
fn pos_div(a: Pos, s: f32) -> Pos { (a.0 / s, a.1 / s) }
fn pos_dist1(a: Pos) -> f32 { f32::sqrt(sqr(a.0) + sqr(a.1)) }
fn pos_rotate(a: Pos, r: f32) -> Pos {
    ((f32::cos(r) * a.0) + (f32::sin(r) * a.1),
     (- f32::sin(r) * a.0) + (f32::cos(r) * a.1))
}

fn draw_line_segment_mut(img: &mut RgbImage, a: Pos, b: Pos, c: Color) {
    draw_antialiased_line_segment_mut(img,
        (a.0.round() as i32, a.1.round() as i32),
        (b.0.round() as i32, b.1.round() as i32),
        c,
        interpolate);
}

fn main() {
    let mut img = RgbImage::from_pixel(728, 728, WHITE);
    koch_curve(&mut img, (5f32, 5f32), (723f32, 723f32), BLACK);
    img.save("koch_curve.png").unwrap();
    let mut img_cave = RgbImage::from_pixel(728, 728, WHITE);
    koch_curve_cave(&mut img_cave, (5f32, 5f32), (723f32, 723f32), BLACK);
    img_cave.save("koch_curve_cave.png").unwrap();
    let mut img_reflected = RgbImage::from_pixel(728, 728, WHITE);
    koch_curve_reflected(&mut img_reflected, (5f32, 5f32), (723f32, 723f32), BLACK);
    img_reflected.save("koch_curve_reflected.png").unwrap();
}

fn koch_curve(img: &mut RgbImage, a: Pos, b: Pos, c: Color) {
    let ab = pos_delta(a, b);
    if pos_dist1(ab) <= DEFAULT_LINE_CUTOFF {
        draw_line_segment_mut(img, a, b, c)
    } else {
        let ab3 = pos_div(ab, 3f32);
        let l = pos_plus(a, ab3);
        let t = pos_plus(l, pos_rotate(ab3, TAU_OVER_6));
        let r = pos_plus(l, ab3);
        koch_curve(img, a, l, c);
        koch_curve(img, l, t, c);
        koch_curve(img, t, r, c);
        koch_curve(img, r, b, c);
    }
}

fn koch_curve_cave(img: &mut RgbImage, a: Pos, b: Pos, c: Color) {
    let ab = pos_delta(a, b);
    if pos_dist1(ab) <= DEFAULT_LINE_CUTOFF {
        draw_line_segment_mut(img, a, b, c)
    } else {
        let ab3 = pos_div(ab, 3f32);
        let l = pos_plus(a, ab3);
        let t = pos_plus(l, pos_rotate(ab3, TAU_OVER_6));
        let r = pos_plus(l, ab3);
        koch_curve_cave(img, t, a, c);
        koch_curve_cave(img, b, t, c);
        koch_curve_cave(img, r, l, c);
    }
}

fn koch_curve_reflected(img: &mut RgbImage, a: Pos, b: Pos, c: Color) {
    let ab = pos_delta(a, b);
    if pos_dist1(ab) <= DEFAULT_LINE_CUTOFF {
        draw_line_segment_mut(img, a, b, c)
    } else {
        let ab3 = pos_div(ab, 3f32);
        let l = pos_plus(a, ab3);
        let t = pos_plus(l, pos_rotate(ab3, TAU_OVER_6));
        let v = pos_plus(l, pos_rotate(ab3, -TAU_OVER_6));
        let r = pos_plus(l, ab3);
        draw_line_segment_mut(img, a, b, c);
        koch_curve_reflected(img, a, l, c);
        koch_curve_reflected(img, l, t, c);
        koch_curve_reflected(img, l, v, c);
        koch_curve_reflected(img, t, r, c);
        koch_curve_reflected(img, v, r, c);
        koch_curve_reflected(img, r, b, c);
    }
}
