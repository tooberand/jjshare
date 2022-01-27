#!/usr/local/bin/python3

from datetime import date, timedelta
import re
from shutil import copy2
import sys

months = {'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
          'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12}

def main():
    wo_meters = sys.argv[1] if len(sys.argv) > 1 else 0
    wo_time = sys.argv[2] if len(sys.argv) > 2 else ""
    wo_type = sys.argv[3] if len(sys.argv) > 3 else ""

    if not wo_time: sys.exit()

    # Backup file
    copy2("/Users/dwaldhei/dano/lb.fit", "/Users/dwaldhei/dano/lb.fit.bak")

    with open("/Users/dwaldhei/dano/lb.fit") as f_in:
        file_content = f_in.read().split('\n')

    new_file = add_workout_to_content(file_content, wo_meters, wo_time, wo_type)

    with open("/Users/dwaldhei/dano/lb.fit", "w") as f_out:
        f_out.write(new_file)

def add_workout_to_content(file_content, wo_meters, wo_time, wo_type):
    new_file = ""
    file_section = "details"
    now = date.today()

    for line in file_content:
        new_line = line.rstrip('\n')

        if file_section == "details":
            # Check for missing entries
            m = re.findall(r'^([A-Z][a-z][a-z]) (\d\d)', new_line)
            if m:
                fits = re.findall(r'\t([\.\w]+)', new_line)
                fit_count = len(fits)
                fit_date = date(now.year, months[m[0][0]], int(m[0][1]))
                fit_date += timedelta(days = fit_count)

                if fit_count <= 7 and fit_date <= now:
                    print("-", fit_count, " ", fit_date, " ", now)
                    while fit_count < 7 and fit_date < now:
                        print("--", fit_count, " ", fit_date, " ", now)
                        tab_count = new_line.count('\t')
                        print(fit_count, "/", tab_count, "Add '.'")
                        if fit_count == tab_count:
                            print("Add '\t.'")
                            new_line += "\t."
                        else:
                            print("Sub '.'")
                            fit_date += timedelta(days = 1)
                            fit_count += 1

                    # if fit_count < 7 and fit_date == now:
                    if fit_date == now:
                        tab_count = new_line.count('\t')
                        print(fit_count, "/", tab_count, "Add 'o'")
                        if fit_count == tab_count:
                            print("Add '\to'")
                            new_line += "\to"
                        else:
                            print("Add 'o'")

            elif re.match(r'DIARY\s*$', new_line):
                file_section = "diary"

        elif file_section == "diary" and re.match(r'^\s*$', new_line):
            new_line += now.strftime("%d%b") + " - Rowing "
            if wo_type: new_line += wo_type + " "
            new_line += f"({wo_meters}/{wo_time})\n"
            file_section = "totals"

        elif file_section == "totals" and re.match(r'Rowing -', new_line):
            m = re.findall(r'Rowing - (\d+) \((.*)(\w)\-(\d+)\)', new_line)
            if m:
                total_total, history, last_month, month_total = m[0]

                current_month = now.strftime("%b")[0:1]
                new_total_total = str(int(total_total) + int(wo_meters))
                new_line = f"Rowing - {new_total_total} ({history}"
                if last_month != current_month or now.strftime("%b%d") == "Jul01":
                    new_line += f"{last_month}-{month_total}/"
                    new_line += f"{current_month}-{wo_meters}"
                else:
                    new_month_total = str(int(month_total) + int(wo_meters))
                    new_line += f"{last_month}-{new_month_total}"

                new_line += ")"
                    
            file_section = "history"

        print(new_line)
        new_file += new_line + "\n"

    return new_file

main()

