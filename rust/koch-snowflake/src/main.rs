extern crate image;
extern crate imageproc;
mod pos;
mod draw;

use pos::*;
use draw::*;

const DEFAULT_LINE_CUTOFF: f32 = 4f32;

fn main() {
    let mut img = RgbImage::from_pixel(728, 728, WHITE);
    koch_curve(&mut img, (5f32, 5f32), (723f32, 723f32), BLACK);
    img.save("koch_curve.png").unwrap();
    let mut img_cave = RgbImage::from_pixel(728, 728, WHITE);
    koch_curve_cave(&mut img_cave, (5f32, 5f32), (723f32, 723f32), BLACK);
    img_cave.save("koch_curve_cave.png").unwrap();
    let mut img_cave2 = RgbImage::from_pixel(728, 728, WHITE);
    koch_curve_cave2(&mut img_cave2, (5f32, 5f32), (723f32, 723f32), BLACK);
    koch_curve_cave2(&mut img_cave2, (723f32, 723f32), (5f32, 5f32), BLACK);
    img_cave2.save("koch_curve_cave2.png").unwrap();
    let mut img_reflected = RgbImage::from_pixel(728, 728, WHITE);
    koch_curve_reflected(&mut img_reflected, (5f32, 5f32), (723f32, 723f32), BLACK);
    img_reflected.save("koch_curve_reflected.png").unwrap();
    let mut img_reflected2 = RgbImage::from_pixel(728, 728, WHITE);
    koch_curve_reflected2(&mut img_reflected2, (5f32, 5f32), (723f32, 723f32), BLACK);
    img_reflected2.save("koch_curve_reflected2.png").unwrap();
}

fn koch_curve(img: &mut RgbImage, a: Pos, b: Pos, c: Color) {
    let ab = pos_delta(a, b);
    if pos_dist1(ab) <= DEFAULT_LINE_CUTOFF {
        draw_line_segment_mut(img, a, b, c)
    } else {
        let ab3 = pos_div(ab, 3f32);
        let l = pos_plus(a, ab3);
        let t = pos_plus(l, pos_rotate(ab3, FRAC_TAU_6));
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
        let t = pos_plus(l, pos_rotate(ab3, FRAC_TAU_6));
        let r = pos_plus(l, ab3);
        koch_curve_cave(img, t, a, c);
        koch_curve_cave(img, b, t, c);
        koch_curve_cave(img, r, l, c);
    }
}

fn koch_curve_cave2(img: &mut RgbImage, a: Pos, b: Pos, c: Color) {
    let ab = pos_delta(a, b);
    if pos_dist1(ab) <= DEFAULT_LINE_CUTOFF {
        draw_line_segment_mut(img, a, b, c)
    } else {
        let ab3 = pos_div(ab, 3f32);
        let l = pos_plus(a, ab3);
        let t = pos_plus(l, pos_rotate(ab3, FRAC_TAU_6));
        let r = pos_plus(l, ab3);
        koch_curve_cave2(img, t, a, c);
        koch_curve_cave2(img, b, t, c);
        koch_curve_cave2(img, l, r, c);
        koch_curve_cave2(img, r, l, c);
    }
}

fn koch_curve_reflected(img: &mut RgbImage, a: Pos, b: Pos, c: Color) {
    let ab = pos_delta(a, b);
    if pos_dist1(ab) <= DEFAULT_LINE_CUTOFF {
        draw_line_segment_mut(img, a, b, c)
    } else {
        let ab3 = pos_div(ab, 3f32);
        let l = pos_plus(a, ab3);
        let t = pos_plus(l, pos_rotate(ab3, FRAC_TAU_6));
        let v = pos_plus(l, pos_rotate(ab3, -FRAC_TAU_6));
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

fn koch_curve_reflected2(img: &mut RgbImage, a: Pos, b: Pos, c: Color) {
    let ab = pos_delta(a, b);
    if pos_dist1(ab) <= DEFAULT_LINE_CUTOFF {
        draw_line_segment_mut(img, a, b, c)
    } else {
        let ab3 = pos_div(ab, 3f32);
        let l = pos_plus(a, ab3);
        let t = pos_plus(l, pos_rotate(ab3, FRAC_TAU_6));
        let v = pos_plus(l, pos_rotate(ab3, -FRAC_TAU_6));
        let r = pos_plus(l, ab3);
        koch_curve_reflected2(img, a, l, c);
        koch_curve_reflected2(img, l, t, c);
        koch_curve_reflected2(img, l, r, c);
        koch_curve_reflected2(img, l, v, c);
        koch_curve_reflected2(img, t, r, c);
        koch_curve_reflected2(img, v, r, c);
        koch_curve_reflected2(img, r, b, c);
    }
}
