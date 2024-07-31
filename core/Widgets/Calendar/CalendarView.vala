/*
* Copyright © 2023 Alain M. (https://github.com/alainm23/planify)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alain M. <alainmh23@gmail.com>
*/

public class Widgets.Calendar.CalendarView : Adw.Bin {
    private Gee.ArrayList <Widgets.Calendar.CalendarDay> days_arraylist;
    private Gtk.Grid days_grid;

    private GLib.DateTime _current_date;
    public GLib.DateTime current_date {
        get {
            var today = new GLib.DateTime.now_local ();
            
            _current_date = new DateTime.local (
                today.get_year (),
                today.get_month (),
                today.get_day_of_month (),
                0,
                0,
                0
            );

            return _current_date;
        }
    }
    
    public signal void day_selected (int day);

    public CalendarView () {
        Object (
            margin_start: 6,
            margin_end: 6
        );
    }

    ~CalendarView() {
        print ("Destroying Widgets.Calendar.CalendarView\n");
    }

    construct {
        days_arraylist = new Gee.ArrayList<Widgets.Calendar.CalendarDay> ();

        days_grid = new Gtk.Grid () {
            column_homogeneous = true,
            row_homogeneous = true
        };

        var col = 0;
        var row = 0;

        for (int i = 0; i < 42; i++) {
            var day = new Widgets.Calendar.CalendarDay ();
            
            day.day_selected.connect ((day) => {
                day_selected_style (day);
            });

            days_grid.attach (day, col, row, 1, 1);
            col = col + 1;

            if (col != 0 && col % 7 == 0) {
                row = row + 1;
                col = 0;
            }

            day.visible = false;
            days_arraylist.add (day);
        }

        child = days_grid;
    }

    public void fill_grid_days (int start_day, int max_day,
        GLib.DateTime day, bool show_day, bool block_past_days) {
        var day_number = 1;

        for (int i = 0; i < 42; i++) {
            var item = days_arraylist [i];
            item.sensitive = true;
            item.visible = true;

            item.remove_css_class ("calendar-today");
            item.remove_css_class ("calendar-day-selected");

            if (i < start_day || i >= max_day + start_day) {
                item.visible = false;
            } else {
                if (block_past_days && generate_date (day, day_number).compare (current_date) <= -1) {
                    item.sensitive = false;
                }

                if (generate_date (day, day_number).compare (current_date) == 0) {
                    item.add_css_class ("calendar-today");
                }

                if (show_day && Utils.Datetime.get_format_date (day).compare (generate_date (day, day_number)) == 0) {
                    item.add_css_class ("calendar-day-selected");
                }

                item.day = day_number;
                day_number = day_number + 1;
            }
        }
    }

    public void clear_style () {
        for (int i = 0; i < 42; i++) {
            var item = days_arraylist [i];
            item.remove_css_class ("calendar-day-selected");
        }
    }

    private GLib.DateTime generate_date (GLib.DateTime date, int day) {
        return new DateTime.local (
            date.get_year (),
            date.get_month (),
            day,
            0,
            0,
            0
        );
    }

    private void day_selected_style (int day) {
        day_selected (day);

        for (int i = 0; i < 42; i++) {
            var day_item = days_arraylist [i];
            day_item.remove_css_class ("calendar-day-selected");
        }
    }
}
