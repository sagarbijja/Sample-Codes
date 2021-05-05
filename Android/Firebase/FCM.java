package com.trilocode.healthmanager;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.TaskStackBuilder;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.media.RingtoneManager;
import android.os.Build;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.trilocode.UploadDocument;
import com.trilocode.healthmanager.fragment.Fragment_All_Events;
import com.trilocode.healthmanager.fragment.Fragment_Diagnosis;
import com.trilocode.healthmanager.fragment.Fragment_Investigation_History;
import com.trilocode.healthmanager.fragment.Fragment_Prescription_History;
import com.trilocode.healthmanager.fragment.Fragment_Treatment_History;
import com.trilocode.healthmanager.fragment.Fragment_Updates_Reviews;
import com.trilocode.healthmanager.pill_reminder.Reminder;

import java.util.Date;
import java.util.Map;
import java.util.Set;

public class FCM extends FirebaseMessagingService {
    public static final String MyPREFERENCES = "HealthPrefs" ;
    @Override
    public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
        super.onMessageReceived(remoteMessage);
        Date d = new Date();
        String CHANNEL_ID = "Amravati"+remoteMessage.getMessageId()+d.getSeconds();
        String CHANNEL_NAME = "Server"+remoteMessage.getMessageId()+d.getSeconds();
        // Check if login
        if(getSharedPreferences(MyPREFERENCES,MODE_PRIVATE).getString("isloggedin","").equals(""))
        {
            return;
        }
        // Build Notification
        Intent intent;

        try
        {
        Map m = remoteMessage.getData();
        String key = (String)m.get("key");
        Log.d("FCM","Activity Key:"+key);
        System.out.println("Activity Key:"+key);
         intent = new Intent(this,MainActivity.class);
         intent.putExtra("key",key);

            // Create the TaskStackBuilder and add the intent, which inflates the back stack
            TaskStackBuilder stackBuilder = TaskStackBuilder.create(this);
            stackBuilder.addNextIntentWithParentStack(intent);


        String title = (String)m.get("title");


        String message = (String)m.get("body");
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            PendingIntent pendingIntent =  stackBuilder.getPendingIntent(0, PendingIntent.FLAG_UPDATE_CURRENT);

        NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this)
                .setLargeIcon(BitmapFactory.decodeResource(this.getResources(), R.mipmap.notification_icon))
                .setContentTitle(title)
                .setSmallIcon(R.drawable.ic_alarm_on_white_24dp)
                .setVibrate(new long[]{1000, 1000, 1000, 1000, 1000 })
                .setContentText(message)
                .setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION))
                .setAutoCancel(true)
                .setOnlyAlertOnce(true)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
        .setContentIntent(pendingIntent);



        NotificationManager manager = (NotificationManager) this.getSystemService(Context.NOTIFICATION_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, CHANNEL_NAME, NotificationManager.IMPORTANCE_HIGH);
            channel.enableVibration(true);
            channel.setLightColor(Color.BLUE);
            channel.enableLights(true);
            channel.setShowBadge(true);
            manager.createNotificationChannel(channel);
        }
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            mBuilder.setChannelId(CHANNEL_ID);
        }
        manager.notify(CHANNEL_ID,7777 ,mBuilder.build());

        }catch (Exception e)
        {
            Log.d("FCM","onMessage:Error:"+e);
        }

    }
}
