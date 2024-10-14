# hex/rgb color transparency calculator:

def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def rgb_to_hex(rgb_color):
    return f"#{rgb_color[0]:02X}{rgb_color[1]:02X}{rgb_color[2]:02X}"

def blend_colors(background, foreground, alpha):
    bg_rgb = hex_to_rgb(background)
    fg_rgb = hex_to_rgb(foreground)

    result_rgb = tuple(
        int((1 - alpha) * bg + alpha * fg)
        for bg, fg in zip(bg_rgb, fg_rgb)
    )

    result_hex = rgb_to_hex(result_rgb)
    return result_hex, result_rgb

# variables, listed in hex format
background_color = "#000000"
foreground_color = "#d5fbd9"
transparency = 0.5

result_hex, result_rgb = blend_colors(background_color, foreground_color, transparency)
print(f"Resulting color (hex): {result_hex}")
print(f"Resulting color (rgb): {result_rgb}")
