package com.trilocode.healthmanager;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Build.VERSION;
import android.os.Bundle;
import android.os.StrictMode;
import android.os.StrictMode.ThreadPolicy.Builder;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.content.res.ResourcesCompat;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentTransaction;

import com.trilocode.healthmanager.fragment.Fragment_Children_Corner;
import com.trilocode.healthmanager.fragment.Fragment_Updates_Reviews;
import com.trilocode.healthmanager.fragment.Fragment_For_Me;
import com.trilocode.healthmanager.fragment.Fragment_General;
import com.trilocode.healthmanager.fragment.Fragment_General_Tips;
import com.trilocode.healthmanager.fragment.Fragment_Diagnosis;
import com.trilocode.healthmanager.fragment.Fragment_Prescription_History;
import com.trilocode.healthmanager.fragment.Fragment_Treatment_History;
import com.trilocode.healthmanager.fragment.Fragment_Women_Corner;
import com.trilocode.healthmanager.pill_reminder.AlarmReceiver;
import com.trilocode.healthmanager.pill_reminder.Pill_MainActivity;
import com.trilocode.healthmanager.pill_reminder.Reminder;
import com.trilocode.healthmanager.pill_reminder.ReminderAddActivity;
import com.trilocode.healthmanager.pill_reminder.ReminderDatabase;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.android.material.navigation.NavigationView;
import com.google.android.material.navigation.NavigationView.OnNavigationItemSelectedListener;
import com.trilocode.healthmanager.fragment.Fragment_Calculate;
import com.trilocode.healthmanager.fragment.Fragment_Workout;
import com.trilocode.healthmanager.fragment.MainFragment;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class MainActivity extends AppCompatActivity implements OnNavigationItemSelectedListener {
    BottomNavigationView bottomNavigation;

     String mTitle;
     String mTime;
     String mDate;
     String mRepeat="true";
     String mRepeatNo="1";
     String mRepeatType="Day";
     String mActive="true";
    ProgressDialog pDialog;

    String responseStr;


    private Calendar mCalendar;
    private int mYear, mMonth, mHour, mMinute, mDay;
    private long mRepeatTime;
    // Values for orientation change
    private static final String KEY_TITLE = "title_key";
    private static final String KEY_TIME = "time_key";
    private static final String KEY_DATE = "date_key";
    private static final String KEY_REPEAT = "repeat_key";
    private static final String KEY_REPEAT_NO = "repeat_no_key";
    private static final String KEY_REPEAT_TYPE = "repeat_type_key";
    private static final String KEY_ACTIVE = "active_key";

    SharedPreferences sharedpreferences;
    SharedPreferences.Editor editor;
    public static final String MyPREFERENCES = "HealthPrefs" ;

    // Constant values in milliseconds
    private static final long milMinute = 60000L;
    private static final long milHour = 3600000L;
    private static final long milDay = 86400000L;
    private static final long milWeek = 604800000L;
    private static final long milMonth = 2592000000L;

    DrawerLayout drawer;
    ImageView imageView1;
    ReminderAddActivity reminderAddActivity;




    NavigationView navigationView;
    Toolbar toolbar;

    ExpandableListView expandableListView;
    CustomExpandableListAdapter expandableListAdapter;
    List<String> lsTitle;
    Map<String,List<String>> lstChild;
    List<Drawable> icons;
//   NavigationManager
    @SuppressLint("ResourceType")
    public void onCreate(Bundle bundle) {
        super.onCreate(bundle);

        if (VERSION.SDK_INT > 21) {
            StrictMode.setThreadPolicy(new Builder().permitAll().build());
        }
        setContentView((int) R.layout.activity_main);

        sharedpreferences = getSharedPreferences(MyPREFERENCES, Context.MODE_PRIVATE);

        mCalendar = Calendar.getInstance();
        getRemindersFormServer();


//        Expandable -------------------------------------------------------------------------------
        expandableListView = (ExpandableListView)findViewById(R.id.expandableListView);
        genData();
        // Add Header

        addDrawerItems();

        this.navigationView = (NavigationView) findViewById(R.id.nav_views);
//        bottomNavigation.setItemIconTintList(null);
        this.imageView1 = (ImageView) findViewById(R.id.setting);
        this.imageView1.setOnClickListener(new View.OnClickListener() {
            public void onClick(View view) {

            }
        });
        if (VERSION.SDK_INT >= 21) {
            Window window = getWindow();
            window.addFlags(Integer.MIN_VALUE);

        }
        this.toolbar = initToolbar();
        DrawerLayout drawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
        this.drawer = drawerLayout;
        ActionBarDrawerToggle actionBarDrawerToggle =
                new ActionBarDrawerToggle(this, drawerLayout, this.toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        this.drawer.addDrawerListener(actionBarDrawerToggle);

        this.drawer.addDrawerListener(new DrawerLayout.SimpleDrawerListener() {
            public void onDrawerClosed(View view) {
            }
            public void onDrawerOpened(View view) {
            }
        });

        actionBarDrawerToggle.syncState();
        this.navigationView.setNavigationItemSelectedListener(this);
        String str = "#ffffff";
        String str2 = "";

        openFragment(MainFragment.newInstance(str2, str2, this));
       

    }

    void genData()
    {
        lsTitle = new ArrayList<>();
        lsTitle.add("Home");
        lsTitle.add("Basic Profile");
        lsTitle.add("My Medical Profile");
        lsTitle.add("Health Tips");
        lsTitle.add("Health Information");
        lsTitle.add("Fitness History");
        lsTitle.add("Events At My Place");
        lsTitle.add("Reminders");
        lsTitle.add("Suggestions");
        lsTitle.add("Logout");


         icons = new ArrayList<>();
        icons.add(ResourcesCompat.getDrawable(getResources(), R.mipmap.menu_home, null));
        icons.add(ResourcesCompat.getDrawable(getResources(), R.drawable.ic_male, null));
        icons.add(ResourcesCompat.getDrawable(getResources(), R.drawable.medical_profile, null));
        icons.add(ResourcesCompat.getDrawable(getResources(), R.drawable.health_info, null));
        icons.add(ResourcesCompat.getDrawable(getResources(), R.drawable.calculator, null));
        icons.add(ResourcesCompat.getDrawable(getResources(), R.mipmap.menu_walk, null));
        icons.add(ResourcesCompat.getDrawable(getResources(), R.drawable.safety, null));

        icons.add(ResourcesCompat.getDrawable(getResources(), R.mipmap.reminder_22, null));


        icons.add(ResourcesCompat.getDrawable(getResources(), R.mipmap.menu_reminder, null));

        icons.add(ResourcesCompat.getDrawable(getResources(), R.drawable.logout, null));


        lstChild = new TreeMap<>();
        lstChild.put("My Medical Profile",(List<String>)Arrays.asList(
                "Diagnosis",
                "Treatment History",
                "Investigations History",
                "Prescription History",
                "Updates"));
        lstChild.put("Health Tips",(List<String>)Arrays.asList(
                "For Me",
                "General Tips"
               ));

        lstChild.put("Health Information",(List<String>)Arrays.asList(
                "General",
                "Women Corner",
                "Children Corner"
        ));
        lstChild.put("Events At My Place",(List<String>)Arrays.asList(
                "Fitness",
                "Dance",
                "Music",
                "Singing",
                "Arts",
                "Drawing",
                "Poetry",
                "Others Events"));

        lstChild.put("Reminders",(List<String>)Arrays.asList(
                "Water Intake",
                "Medication"));
    }
    void switchTo(String title)
    {

        Log.d("MainActivity", "switchTo: "+title);
//        toolbar.setTitle(title);
            String str="";


            Intent i;
            switch (title) {
                case "Home":
                    toolbar.setTitle(getString(R.string.app_name));
                    MainActivity.this.openFragment(MainFragment.newInstance(str, str, MainActivity.this));
                    break;
                case "Basic Profile":
                    toolbar.setTitle(title);
                    MainActivity.this.openFragment(PROFILE.newInstance(str, str));
                    break;
//              Medical Profile :- cases #######################################
                case "Diagnosis":
                    toolbar.setTitle(title);
                    MainActivity.this.openFragment(Fragment_Diagnosis.newInstance(str, str));
                    break;
                case "Treatment History":
                 toolbar.setTitle(title);
                    MainActivity.this.openFragment(Fragment_Treatment_History.newInstance(str, str));
                    break;
                case "Prescription History":
                    toolbar.setTitle(title);
                    MainActivity.this.openFragment(Fragment_Prescription_History.newInstance(str, str));
                    break;
                case "Investigations History":
                    toolbar.setTitle(title);
//                    MainActivity.this.openFragment(Fragment_Investigation_History.newInstance(str, str));
                    MainActivity.this.openFragment(Attach_Document.newInstance(str, str));
                    break;
                case "Updates":
                    toolbar.setTitle(title);
                    MainActivity.this.openFragment(Fragment_Updates_Reviews.newInstance(str, str));
                    break;
//                    Health Tips : -
                case "For Me":
                    toolbar.setTitle(title);
                    MainActivity.this.openFragment(Fragment_For_Me.newInstance(str, str));
                    break;
                case "General Tips":
                    toolbar.setTitle(title);
                    MainActivity.this.openFragment(Fragment_General_Tips.newInstance(str, str));
                    break;
//                    Health Information :-

                case "General":
                    toolbar.setTitle(title);
                    MainActivity.this.openFragment(Fragment_General.newInstance(str, str));
                    break;
                case "Women Corner":
                    toolbar.setTitle(title);
                    MainActivity.this.openFragment(Fragment_Women_Corner.newInstance(str, str));
                    break;
//              Health Information :- cases #######################################
                case "Children Corner":
                    toolbar.setTitle(title);
                    MainActivity.this.openFragment(Fragment_Children_Corner.newInstance(str, str));
                    break;

//                Events At My Place

                case "Events At My Place":
                case "Fitness":
                case "Dance":
                case "Music":
                case "Singing":
                case "Arts":
                case "Drawing":
                case "Poetry":
                case "Others Events":
                    toolbar.setTitle(title);
                    MainActivity.this.openFragment(Events.newInstance(title, str));
                    break;
//              Calculators :- cases #######################################
                case "Calculator":
                    toolbar.setTitle("Calculator");
                    MainActivity.this.openFragment(Fragment_Calculate.newInstance(str, str));
                    break;
                case "Workouts":
                    toolbar.setTitle("Workouts");
                    Toast.makeText(getApplicationContext(),"Workout",Toast.LENGTH_SHORT).show();
                    MainActivity.this.openFragment(Fragment_Workout.newInstance(str, str));
                    break;
                case "Water Intake":
                    i = new Intent(MainActivity.this, Water_MainActivity.class);
                    startActivity(i);
                    break;
                case "Medication":
                    i = new Intent(MainActivity.this, Pill_MainActivity.class);
                    startActivity(i);
                    break;
                case "Suggestions":
                    toolbar.setTitle("Suggestions");
                    MainActivity.this.openFragment(Suggestion.newInstance(str, str));
                    break;
                case "Logout":
                    logout();
                    break;
                 default:
                     str="#";
            }
            if(!str.equals("#"))
                this.drawer.closeDrawer((int) GravityCompat.START);


    }
    private void addDrawerItems() {
        expandableListAdapter = new CustomExpandableListAdapter(this,lsTitle,lstChild,icons);
        expandableListView.setAdapter(expandableListAdapter);
        expandableListView.setOnGroupExpandListener(new ExpandableListView.OnGroupExpandListener() {
            @Override
            public void onGroupExpand(int groupPosition) {
                switchTo((String)lsTitle.get(groupPosition));
            }
        });

        expandableListView.setOnChildClickListener(new ExpandableListView.OnChildClickListener() {
            @Override
            public boolean onChildClick(ExpandableListView parent, View v, int groupPosition, int childPosition, long id) {
                String selectedItem = (String)lstChild.get(lsTitle.get(groupPosition)).get(childPosition);
                switchTo(selectedItem);
                return false;
            }
        });

    }

    public void openFragment(Fragment fragment) {
        FragmentTransaction beginTransaction = getSupportFragmentManager().beginTransaction();
        beginTransaction.replace(R.id.nav_host_fragment, fragment);
        beginTransaction.addToBackStack(null);
        beginTransaction.commit();
    }

    public void loadFragmentworkout(Fragment fragment) {
        FragmentTransaction beginTransaction = getSupportFragmentManager().beginTransaction();
        beginTransaction.replace(R.id.nav_host_fragment, fragment);
        beginTransaction.addToBackStack(null);
        beginTransaction.commit();
        toolbar.setTitle("workout");
;
    }

    public void loadFragment_water(Fragment fragment) {
        FragmentTransaction beginTransaction = getSupportFragmentManager().beginTransaction();
        beginTransaction.replace(R.id.nav_host_fragment, fragment);
        beginTransaction.addToBackStack(null);
        beginTransaction.commit();
        toolbar.setTitle("Walk & Step");

    }

    private Toolbar initToolbar() {
        Toolbar toolbar2 = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar2);
        return toolbar2;
    }




    public boolean onNavigationItemSelected(MenuItem menuItem) {
        int itemId = menuItem.getItemId();

        String str = "android.intent.extra.TEXT";
        String str2 = "android.intent.extra.SUBJECT";

  

            return true;
    }
        public void onBackPressed () {
            final Dialog dialog = new Dialog(this);
            dialog.setContentView(R.layout.adview_layout_exit);
            ((Button) dialog.findViewById(R.id.btnno)).setOnClickListener(new View.OnClickListener() {
                public void onClick(View view) {
                    dialog.dismiss();
                }
            });
            ((Button) dialog.findViewById(R.id.btnyes)).setOnClickListener(new View.OnClickListener() {
                public void onClick(View view) {
                    dialog.dismiss();
                    MainActivity.this.finish();
                }
            });
            dialog.show();
        }

     public void getRemindersFormServer() {
         pDialog = new ProgressDialog(getApplicationContext());

         class SendPostReqAsyncTask extends AsyncTask<String, Void, String> {

             @Override
             protected void onPreExecute() {
                 super.onPreExecute();
                 pDialog = new ProgressDialog(MainActivity.this);
                 pDialog.setMessage("Please wait...");
                 pDialog.setCancelable(false);
                 pDialog.show();
             }

             @Override
             protected String doInBackground(String... params) {

                 List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();
                 nameValuePairs.add(new BasicNameValuePair("mobile",sharedpreferences.getString("mob","")));
                 nameValuePairs.add(new BasicNameValuePair("sevarth_no",sharedpreferences.getString("sevarth_no","")));
                 try {
                     HttpClient httpClient = new DefaultHttpClient();
                     HttpPost httpPost = new HttpPost("http://trilocode.com/demo/HealthCare/get_reminder.php");

                     HttpResponse httpResponse = httpClient.execute(httpPost);
                     HttpEntity httpEntity = httpResponse.getEntity();
                     if(httpEntity!=null) {
                         responseStr = EntityUtils.toString(httpResponse.getEntity());
                     }
                     System.out.println("result="+responseStr);
                 } catch (ClientProtocolException e) {

                 } catch (IOException e) {

                 }
                 return responseStr;
             }

             @Override
             protected void onPostExecute(String result) {
                 super.onPostExecute(result);
                 if (pDialog.isShowing())
                     pDialog.dismiss();
                 saveReminders();


             }
         }
         SendPostReqAsyncTask sendPostReqAsyncTask = new SendPostReqAsyncTask();
         sendPostReqAsyncTask.execute();
}
    public void saveReminders(){
        ReminderDatabase rb = new ReminderDatabase(this);
        int ID = -1;
        try {
            // Parse Json
            JSONObject jsonObject = new JSONObject(responseStr);
            JSONArray jsonArray = jsonObject.getJSONArray("data");


            for(int i=0;i<jsonArray.length();i++) {
                jsonObject = jsonArray.getJSONObject(i);
 
                // Delete the Reminder
                if(jsonObject.getInt("status")==0)
                {
                    ID = Integer.parseInt(jsonObject.getString("id"));
                    rb.deleteReminder_(ID);
                    new AlarmReceiver().cancelAlarm(getApplicationContext(),ID);
                    break;
                }
                // Add Reminder if ONLY New
                ID = rb.addReminder(new Reminder(
                        jsonObject.getString("id"),
                        jsonObject.getString("name"),
                        jsonObject.getString("rdate"),
                        jsonObject.getString("rtime"),
                        "true",
                        "1",
                        jsonObject.getString("rtype"),
                        "true"));
                // Old Record
                if(ID==-1)
                    break;

                // Create Calender for Alarm
                mRepeatType = jsonObject.getString("rtype");
                String[] mDateSplit = jsonObject.getString("rdate").split("-");
                String[] mTimeSplit = jsonObject.getString("rtime").split(":");
                mYear = Integer.parseInt(mDateSplit[0]);
                mMonth = Integer.parseInt(mDateSplit[1]);
                mDay = Integer.parseInt(mDateSplit[2]);
                mHour = Integer.parseInt(mTimeSplit[0]);
                mMinute = Integer.parseInt(mTimeSplit[1]);
                mCalendar = Calendar.getInstance();

                mCalendar.set(Calendar.HOUR_OF_DAY, mHour);
                mCalendar.set(Calendar.MINUTE, mMinute);
                mCalendar.set(Calendar.SECOND, 0);

                // Check repeat type
                if (mRepeatType.equals("Minute")) {
                    mRepeatTime = Integer.parseInt(mRepeatNo) * milMinute;
                } else if (mRepeatType.equals("Hour")) {
                    mRepeatTime = Integer.parseInt(mRepeatNo) * milHour;
                } else if (mRepeatType.equals("Day")) {
                    mRepeatTime = Integer.parseInt(mRepeatNo) * milDay;
                } else if (mRepeatType.equals("Week")) {
                    mRepeatTime = Integer.parseInt(mRepeatNo) * milWeek;
                } else if (mRepeatType.equals("Month")) {
                    mRepeatTime = Integer.parseInt(mRepeatNo) * milMonth;
                }
                Log.d("Reminder Set", "saveReminders: "+mCalendar.toString());
                // Create a new notification
                if (mActive.equals("true")) {
                    if (mRepeat.equals("true")) {
                        new AlarmReceiver().setRepeatAlarm(getApplicationContext(), mCalendar, ID, mRepeatTime);
                    } else if (mRepeat.equals("false")) {
                        new AlarmReceiver().setAlarm(getApplicationContext(), mCalendar, ID);
                    }
                }
                Toast.makeText(getApplicationContext(), "New Reminder Added",
                        Toast.LENGTH_SHORT).show();
            }
        }catch (Exception e)
        {
            Log.d("MainActivity", "saveReminders: "+e);
            Toast.makeText(getApplicationContext(), "Error While Adding New Reminders",
                    Toast.LENGTH_SHORT).show();
        }
        // Create toast to confirm new reminder
    }

    @Override
    protected void onResume() {
        super.onResume();

    }

    void logout()
    {
     sharedpreferences.edit().clear().commit();
     startActivity(new Intent(MainActivity.this,Login.class));
     finish();
    }
}
