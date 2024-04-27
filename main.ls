[w, h] = [1200, 400]
get_dim = (head, body, cone, corner) ->
  if head < 0 then head = 0
  if body <= head then body = head+0.1
  if cone <= 0 then cone = 0.1
  if corner < 0 then corner = 0

  full_l = 25.4*8
  head_angle = Math.atan2((body - head)/2, cone*(body - head)/8); # head_arc = M.PI/2 + @ ~ M.PI*3/2 - @
  head_r = head/2 / Math.cos(head_angle)
  head_l = head_r * (1 - Math.sin(head_angle))
  head_h = head_r * Math.cos(head_angle)
  corner_r = corner / Math.sin(head_angle/2)/2
  corner_l = corner_r * Math.sin(head_angle)
  corner_h = corner_r * (Math.cos(head_angle) - 1) + body/2
  cone_l = (corner_h - head_h)*2 / 8 * cone
  ring_angle = Math.acos((5-1)/5)
  foot_angle = ring_angle + Math.PI/2
  ring_l = 5 * Math.sin(ring_angle)
  foot_l = 5 * (1-Math.cos(foot_angle))
  body_l = full_l - head_l - cone_l - corner_l - ring_l - foot_l
  {
    full_l, head_angle
    head_r, head_l, head_h
    corner_r, corner_l, corner_h
    cone_l
    ring_angle, foot_angle
    ring_l, foot_l, body_l
  }

get_stl = (head, body, cone, corner) ->
  if head < 0 then head = 0
  if body <= head then body = head+0.1
  if cone <= 0 then cone = 0.1
  if corner < 0 then corner = 0

  {
    full_l, head_angle
    head_r, head_l, head_h
    corner_r, corner_l, corner_h
    cone_l
    ring_angle, foot_angle
    ring_l, foot_l, body_l
  } = get_dim(head, body, cone, corner)

  if body_l < 0 then return void

  delta = 0.05
  put_cone = (z0, z1, r0, r1) !->
    r_max = Math.max(r0, r1)
    r_max * (1-cos(th/2)) < delta
    1-cos(th/2) < delta / r_max

draw = (head, body, cone, corner) ->
  scale = 4
  pad_x = 10

  if head < 0 then head = 0
  if body <= head then body = head+0.1
  if cone <= 0 then cone = 0.1
  if corner < 0 then corner = 0

  {
    full_l, head_angle
    head_r, head_l, head_h
    corner_r, corner_l, corner_h
    cone_l
    ring_angle, foot_angle
    ring_l, foot_l, body_l
  } = get_dim(head, body, cone, corner)

  if body_l < 0 then return 0

  canvas = document.querySelector('canvas')
    ..width = w
    ..height = h

  y = h / 2
  x = 10
  ctx = canvas.getContext \2d

  # head
  ctx.fillStyle = \#ff99f1
  ctx.beginPath()
  ctx.moveTo(pad_x + (head_l)*scale, y+head_h*scale)
  ctx.arc(pad_x + (head_r)*scale, y, head_r*scale, Math.PI/2+head_angle, Math.PI*3/2-head_angle)
  ctx.closePath()
  ctx.fill()

  # cone
  ctx.fillStyle = '#b399ff';
  ctx.beginPath();
  ctx.moveTo(pad_x + head_l*scale, y - head_h*scale);
  ctx.lineTo(pad_x + (head_l + cone_l)*scale, y - corner_h*scale);
  ctx.lineTo(pad_x + (head_l + cone_l)*scale, y + corner_h*scale);
  ctx.lineTo(pad_x + head_l*scale, y + head_h*scale);
  ctx.closePath();
  ctx.fill();

  # corner
  ctx.fillStyle = '#ff99f1';
  ctx.beginPath();
  ctx.moveTo(pad_x + (head_l + cone_l)*scale, y+corner_h*scale);
  ctx.lineTo(pad_x + (head_l + cone_l)*scale, y - corner_h*scale);
  ctx.arc(pad_x + (head_l + cone_l + corner_l)*scale, y - (body/2-corner_r)*scale, corner_r*scale, Math.PI*3/2-head_angle, Math.PI*3/2);
  ctx.lineTo(pad_x + (head_l + cone_l + corner_l)*scale, y+body/2*scale);
  ctx.arc(pad_x + (head_l + cone_l + corner_l)*scale, y+(body/2-corner_r)*scale, corner_r*scale, Math.PI/2, Math.PI/2+head_angle);
  ctx.closePath();
  ctx.fill();

  # body
  ctx.fillStyle = '#b399ff';
  ctx.beginPath();
  ctx.moveTo(pad_x + (head_l + cone_l + corner_l)*scale, y - body/2*scale);
  ctx.lineTo(pad_x + (head_l + cone_l + corner_l)*scale, y + body/2*scale);
  ctx.lineTo(pad_x + (head_l + cone_l + corner_l + body_l)*scale, y + body/2*scale);
  ctx.lineTo(pad_x + (head_l + cone_l + corner_l + body_l)*scale, y - body/2*scale);
  ctx.closePath();
  ctx.fill();

  # ring
  ctx.fillStyle = '#ff99f1';
  ctx.beginPath();
  ctx.moveTo(pad_x + (head_l + cone_l + corner_l + body_l)*scale, y - body/2*scale);
  ctx.lineTo(pad_x + (head_l + cone_l + corner_l + body_l)*scale, y + body/2*scale);
  ctx.arc(pad_x + (head_l + cone_l + corner_l + body_l)*scale, y + (body/2+5)*scale, 5*scale, Math.PI*3/2, Math.PI*3/2+ring_angle);
  ctx.lineTo(pad_x + (head_l + cone_l + corner_l + body_l + ring_l)*scale, y - (body/2+1)*scale);
  ctx.arc(pad_x + (head_l + cone_l + corner_l + body_l)*scale, y - (body/2+5)*scale, 5*scale, Math.PI/2-ring_angle, Math.PI/2);
  ctx.closePath();
  ctx.fill();

  # foot
  ctx.fillStyle = '#b399ff';
  ctx.beginPath();
  ctx.moveTo(pad_x + (head_l + cone_l + corner_l + body_l + ring_l)*scale, y + (body/2+1)*scale);
  ctx.lineTo(pad_x + (head_l + cone_l + corner_l + body_l + ring_l)*scale, y - (body/2+1)*scale);
  ctx.arc(pad_x + (head_l + cone_l + corner_l + body_l + ring_l + foot_l - 5)*scale, y - (body/2+2-5)*scale, 5*scale, Math.PI*3/2-ring_angle, Math.PI*2);
  ctx.arc(pad_x + (head_l + cone_l + corner_l + body_l + ring_l + foot_l - 5)*scale, y + (body/2+2-5)*scale, 5*scale, 0, Math.PI/2+ring_angle);
  ctx.closePath();
  ctx.fill();

  return head_l + cone_l + corner_l;

app = Vue.createApp do
  data: -> do
    head_input: 27
    head_unit: 'mm'
    body_input: 35
    body_unit: 'mm'
    cone_input: 3
    cone_unit: 'in'
    corner_input: 10
    corner_unit: 'mm'
    full: 3.7012458813119564

  computed: do
    head: -> @head_input * (if @head_unit=='mm' then 1 else 25.4)
    body: -> @body_input * (if @body_unit=='mm' then 1 else 25.4)
    cone: -> @cone_input * (if @cone_unit=='mm' then 1 else 25.4)
    corner: -> @corner_input * (if @corner_unit=='mm' then 1 else 25.4)

  watch: do
    head: !-> @draw()
    body: !-> @draw()
    cone: !-> @draw()
    corner: !-> @draw()

  methods: do
    draw: !->
      @full = draw(@head, @body, @cone, @corner) / 25.4

app.mount('#body');
draw(27, 35, 76.2, 10);
