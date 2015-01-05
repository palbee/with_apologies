"use strict";

GLIDER_GUN = [
  29, 4
  27, 5
  29, 5
  17, 6
  18, 6
  25, 6
  26, 6
  39, 6
  40, 6
  16, 7
  20, 7
  25, 7
  26, 7
  39, 7
  40, 7
  5, 8
  6, 8
  15, 8
  21, 8
  25, 8
  26, 8
  5, 9
  6, 9
  15, 9
  19, 9
  21, 9
  22, 9
  27, 9
  29, 9
  15, 10
  21, 10
  29, 10
  16, 11
  20, 11
  17, 12
  18, 12
]

ROWS = 50
COLUMNS = 75


RULES =
  "2_live": 'live'
  "3_live": 'live'
  "3_dead": 'live'
  next_state: (col, row, neighbors) ->
    lookup = neighbors + '_' + get_state(col, row)
    if this.hasOwnProperty(lookup)
      this[lookup]
    else
      'dead'

make_name = (col, row) ->
  'cell' + '_' + col + '_' + row

make_id = (col, row) ->
  '#' + make_name(col, row)

set_state = (col, row, state) ->
  $(make_id(col, row)).attr class: state
#  $(make_id(col, row)).text(state[0])

torus = (col, row) ->
  # Make the universe a torus
  if col > COLUMNS
    col = 1
  else if col < 1
    col = COLUMNS

  if row > ROWS
    row = 1
  else if row < 1
    row = ROWS
  [col, row]

get_state_numeric = (col, row) ->
  # if cell is live returns 1, 0 otherwise
#  [col, row] = torus(col, row)
  if $(make_id(col, row)).hasClass('live')
    1
  else
    0

get_state = (col, row) ->
  ['dead', 'live'][get_state_numeric(col, row)]


toggle = (cell_id) ->
  if $("#control")[0].value == "run"
    return
  if $(cell_id).hasClass('live')
    $(cell_id).attr class: 'dead'
    $(cell_id).innerText = "D"
  else
    $(cell_id).attr class: 'live'
    $(cell_id).innerText = "L"


count_neighbors = (col, row) ->
  # returns the count of the 8 neighborhood
  total =  get_state_numeric(col-1, row-1)  + get_state_numeric(col, row-1) + get_state_numeric(col+1, row-1)
  total += get_state_numeric(col-1, row)                                    + get_state_numeric(col+1, row)
  total +  get_state_numeric(col-1, row+1)  + get_state_numeric(col, row+1) + get_state_numeric(col+1, row+1)

update_table = (columns, rows) ->
  counts = for row in [1..rows]
    for col in [1..columns]
      count_neighbors(col, row)
  for row in [1..rows]
    do (counts) ->
      for col in [1..columns]
        do (counts) ->
          try
            set_state(col, row, RULES.next_state(col, row, counts[row-1][col-1]))
          catch err
            console.log(err)
            console.log(col)
            console.log(row)

create_table = (div, columns, rows) ->
  # Create the table for displaying the progress of the life game.
  table = document.createElement('table')
  for row in [1..rows]
    do (table) ->
      tr = document.createElement('tr')
      for col in [1..columns]
        do (tr) ->
          label = 'cell_'+col+'_'+row
          td = document.createElement('td')
          td.id = label
          td.className = "dead"
          $(td).bind('click', (event) =>
            toggle(event.target)
          )
          tr.appendChild(td)
      table.appendChild(tr)
  $(div).append(table)

list_cells = (div, columns, rows) ->
  $(div)[0].innerHTML = '<pre id="coord_list"></pre>'
  for row in [1..rows]
    for col in [1..columns]
      if get_state(col, row) == 'live'
         $("#coord_list").append(col + ", " + row + "\n")
$(document).ready( () ->
  create_table("#life", COLUMNS, ROWS)
  index = 0;
  while index < GLIDER_GUN.length
    set_state(GLIDER_GUN[index], GLIDER_GUN[index+1], 'live')
    index += 2

  $("#list_button").bind('click', () ->
    list_cells("#list_cells", COLUMNS, ROWS)
  )

  $("#control").bind('click', () ->
    if $("#control")[0].value == "run"
      $("#control")[0].innerHTML = "Run"
      $("#control")[0].value = "stop"
    else
      $("#control")[0].innerHTML = "Stop"
      $("#control")[0].value = "run"

  )

  setInterval(
    () ->
      if $("#control")[0].value == "run"
        update_table(COLUMNS, ROWS)
    100
  )
)