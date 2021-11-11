extern float white_scale;

vec4 effect(vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord)
{
    vec4 c = Texel(tex, texcoord) * vcolor;
    c.rgb += vec3(white_scale);
    return c;
}
