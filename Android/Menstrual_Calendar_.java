package com.trilocode.healthmanager.women_corner;

import androidx.appcompat.app.AppCompatActivity;

import android.app.DatePickerDialog;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import com.trilocode.healthmanager.R;
import com.trilocode.healthmanager.health_information.General_Info_Page;

import java.text.DateFormatSymbols;
import java.util.Calendar;

public class Menstrual_Calendar_ extends AppCompatActivity {

    LinearLayout weekdays;
    TableLayout calender;
    DatePicker datePicker;
    Button userDate;
    GridView weekdates,weekdates_;
    DateFormatSymbols dfs;
    private int  mYear, mMonth, mDay, mHour, mMinute;
    TextView month1,month2;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_menstrual__calendar_);
        final GridView weekdays = (GridView)findViewById(R.id.weekdays);
        weekdays.setAdapter(new WeekDays());

        final GridView weekdays_ = (GridView)findViewById(R.id.weekdays_);
        weekdays_.setAdapter(new WeekDays());
        userDate = findViewById(R.id.user_date);
       weekdates = (GridView)findViewById(R.id.days);
        weekdates_ =  (GridView)findViewById(R.id.days_);
        month1 = findViewById(R.id.month1);
        month2 = findViewById(R.id.month2);
        dfs = new DateFormatSymbols();
        userDate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                final Calendar c = Calendar.getInstance();
                mYear = c.get(Calendar.YEAR);
                mMonth = c.get(Calendar.MONTH);
                mDay = c.get(Calendar.DAY_OF_MONTH);

                DatePickerDialog datePickerDialog = new DatePickerDialog(Menstrual_Calendar_.this,
                        new DatePickerDialog.OnDateSetListener() {

                            @Override
                            public void onDateSet(DatePicker view, int year,
                                                  int monthOfYear, int dayOfMonth) {

                                userDate.setText(dayOfMonth + "-" + (monthOfYear + 1) + "-" + year);

                                month1.setText(dfs.getMonths()[monthOfYear]);
                                WeekDates wk = new WeekDates(dayOfMonth,monthOfYear,year,0);
                                weekdates.setAdapter(wk);

                               // Continue Month
                                Calendar cal = Calendar.getInstance();
                                cal.set(Calendar.MONTH,monthOfYear);
                                cal.set(Calendar.DAY_OF_MONTH, dayOfMonth);


                               if(monthOfYear==11)
                               {
                                   dayOfMonth = 1;
                                   monthOfYear = 0;
                                   year++;
                               }
                               else
                               {
                                   dayOfMonth = 1;
                                   monthOfYear++;
                               }
                                month2.setText(dfs.getMonths()[monthOfYear]);

                                weekdates_.setAdapter(new WeekDates(dayOfMonth,monthOfYear,year,wk.getLastSym()));


                            }
                        }, mYear, mMonth, mDay);
                datePickerDialog.show();
            }
        });




  }

    public void openPage(View view) {
        Intent i = new Intent(Menstrual_Calendar_.this, General_Info_Page.class);
        i.putExtra("title","Menstrual Cycle");
        i.putExtra("title_m","मासिक पाळी");
        i.putExtra("content",R.string.menstrual_cycle);
        startActivity(i);
    }

    class WeekDays extends BaseAdapter {
        String[] weekdays = null;


        WeekDays()
        {
            WeekDayAdapter();
        }
        public void WeekDayAdapter() {
            DateFormatSymbols dateFormatSymbols= new DateFormatSymbols();
            weekdays  = dateFormatSymbols.getShortWeekdays();
        }
        public int getCount() {
            return 7;
        }

        public Object getItem(int position) {
            return weekdays[position];
        }

        public long getItemId(int position) {
            return GridView.INVALID_ROW_ID;
        }

        public View getView(int position, View convertView, ViewGroup parent) {
            LinearLayout view = null;

            view = new LinearLayout(parent.getContext());
            view.setLayoutParams(new GridView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
            view.setOrientation(LinearLayout.HORIZONTAL);
            view.setGravity(Gravity.CENTER);
            LinearLayout linearLayout = new LinearLayout(parent.getContext());
            linearLayout.setOrientation(LinearLayout.VERTICAL);

            TextView weekDays = new TextView(parent.getContext());
            weekDays.setGravity(Gravity.CENTER);
            weekDays.setTextAlignment(View.TEXT_ALIGNMENT_CENTER);
            weekDays.setText(weekdays[position + 1]);

            linearLayout.addView(weekDays);
            view.addView(linearLayout);
            return view;
        }
    }


    class WeekDates extends BaseAdapter {
        String[] weekdays = null;
        int firstWeek = 0;
        int numDays = 0 ;
        boolean isEmptyFilled = false;
        int day=1;
        int statusSym = 0;

        String[][] days = new  String[42][2];
        WeekDates(int date, int month,int year,int continueFrom)
        {

            this.statusSym = continueFrom;
//            WeekDayAdapter();
            Calendar cal = Calendar.getInstance();
            cal.set(Calendar.MONTH,month);
            cal.set(Calendar.DAY_OF_MONTH, 1);
            cal.set(Calendar.YEAR,year);
            firstWeek = cal.get(Calendar.DAY_OF_WEEK);
            numDays = cal.getActualMaximum(Calendar.DAY_OF_MONTH);


            for(int i=0;i<42;i++)
            {
                days[i][1] = "_";
                if(firstWeek>(i+1))
                {
                    days[i][0] = " ";
                }else
                {
                    if(day<=numDays)
                    {
                        if(day>=date) {
                            // For Icons
                            if (statusSym < 5)
                                days[i][1] = "B";
                            else if (statusSym < 9)
                                days[i][1] = "S";
                            else if(statusSym==13)
                                days[i][1] = "O";
                            else if (statusSym < 17)
                                days[i][1] = "U";
                            else if (statusSym < 28)
                                days[i][1] = "S";
                            else {
                                days[i][1] = "B";
                                statusSym = 0;
                            }
                            statusSym++;
                        }
                        days[i][0] = ""+day;
                        day++;

                    }
                    else
                    {
                        days[i][0] = " ";
                    }

                }
            }
        }

        int getLastSym()
        {
            return this.statusSym;
        }

        public int getCount() {
            return firstWeek==6 && numDays>30 ? 42 : 35;
        }

        public Object getItem(int position) {
            return position;
        }

        public long getItemId(int position) {
            return GridView.INVALID_ROW_ID;
        }

        public View getView(int position, View convertView, ViewGroup parent) {
            View view = null;
            view = getLayoutInflater().inflate(R.layout.date_layout, null);
            System.out.println("Pos:"+position);
            System.out.println("NumDays:"+numDays);
            System.out.println("FirstWeek:"+firstWeek);


            ((TextView)view.findViewById(R.id.date)).setText(days[position][0]);


            switch (days[position][1])
            {
                case "B": ((ImageView)view.findViewById(R.id.icon)).setBackgroundResource(R.drawable.blood_drop); break;
                case "S": ((ImageView)view.findViewById(R.id.icon)).setBackgroundResource(R.drawable.safe_day); break;
                case "U": ((ImageView)view.findViewById(R.id.icon)).setBackgroundResource(R.drawable.unsafe_day); break;
                case "O": ((ImageView)view.findViewById(R.id.icon)).setBackgroundResource(R.drawable.unsafe_day);
                    view.setBackgroundColor(Color.YELLOW); break;

            }





            return view;
        }
    }
}