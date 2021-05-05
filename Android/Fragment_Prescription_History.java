package com.trilocode.healthmanager.fragment;

import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.net.Uri;
import android.os.Bundle;

import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.RecyclerView;

import android.provider.MediaStore;
import android.util.Base64;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.bumptech.glide.Glide;
import com.trilocode.healthmanager.Configs;
import com.trilocode.healthmanager.R;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.util.HashMap;
import java.util.Map;

public class Fragment_Prescription_History extends Fragment {
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";
    private static final String TAG = "Prescription";
    ImageView iv_doc;
    Button bt_doc;
    EditText et_doc_name;
    private static final int pic_id = 123;
    int img_status = 0;
    Bitmap btimap_iv;
    String encodebefore, responseStr = "", doc_type = "";
    int type;
    private JSONObject json;
    ProgressDialog pDialog;
    private String mParam1;
    private String mParam2;
    View v;
    String ServerURL = "http://trilocode.com/demo/HealthCare/doc_upload.php";
    String mob;
    SharedPreferences sharedpreferences;
    SharedPreferences.Editor editor;
    public static final String MyPREFERENCES = "HealthPrefs";
    String strUrl;

    RecyclerView recyclerView;
    Dialog uploadDialog;
    final int GALLERY = 1, CAMERA = 2;
    JSONArray documents;
    DocumentViewAdapter documentViewAdapter;
    ListView documentListView;
    RequestQueue queue;

    public Fragment_Prescription_History() {
        // Required empty public constructor
    }

    public static Fragment_Prescription_History newInstance(String param1, String param2) {
        Fragment_Prescription_History fragment = new Fragment_Prescription_History();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        v = inflater.inflate(R.layout.fragment__prescription__history, container, false);

        sharedpreferences = getActivity().getSharedPreferences(MyPREFERENCES, Context.MODE_PRIVATE);
        editor = sharedpreferences.edit();

        mob = sharedpreferences.getString("mob", null);
        strUrl = "http://trilocode.com/demo/HealthCare/get_doc.php?mob=" + mob;

        System.out.println(strUrl);
        iv_doc = (ImageView) v.findViewById(R.id.iv_document);
        bt_doc = (Button) v.findViewById(R.id.btn_doc_submit);
        et_doc_name = v.findViewById(R.id.et_doc_name);
        documentListView = v.findViewById(R.id.doc_list);

        getMyPrescription();

        // URL to the JSON data

//        recyclerView = v.findViewById(R.id.doc_recylcerView);
//        recyclerView.setHasFixedSize(true);
//        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));

        //initializing the productlist
//        productList = new ArrayList<>();

        //this method will fetch and parse json
        //to display it in recyclerview
//        loadProducts();

        iv_doc.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Show Dialog Box ->>>>>>
                uploadDialog = new Dialog(getActivity());
                View dView = getLayoutInflater().inflate(R.layout.upload_choice, null);
                uploadDialog.setContentView(dView);
                uploadDialog.show();
                // Gallery (choice)
                ((LinearLayout) dView.findViewById(R.id.gallery)).setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        uploadDialog.dismiss();
                        if (ContextCompat.checkSelfPermission(
                                getActivity(), android.Manifest.permission.WRITE_EXTERNAL_STORAGE) ==
                                PackageManager.PERMISSION_GRANTED) {
                            Intent pickPhoto = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
                            startActivityForResult(pickPhoto, GALLERY);
                        } else {
                            // You can directly ask for the permission.
                            getActivity().requestPermissions(new String[]{android.Manifest.permission.WRITE_EXTERNAL_STORAGE}, 12);
                        }

                    }
                });
                // Camera (choice)
                ((LinearLayout) dView.findViewById(R.id.camera)).setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        uploadDialog.dismiss();
                        Intent camera_intent
                                = new Intent(MediaStore
                                .ACTION_IMAGE_CAPTURE);
                        startActivityForResult(camera_intent, CAMERA);

                    }
                });

            }
        });
        bt_doc.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (img_status == 0) {
                    Toast.makeText(getContext(), "Please Capture Photo", Toast.LENGTH_SHORT).show();
                } else {
                    try {
                        btimap_iv = ((BitmapDrawable) iv_doc.getDrawable()).getBitmap();
                        ByteArrayOutputStream signArrayOutputStream = new ByteArrayOutputStream();
                        btimap_iv.compress(Bitmap.CompressFormat.JPEG, 50, signArrayOutputStream);
                        encodebefore = Base64.encodeToString(signArrayOutputStream.toByteArray(), Base64.DEFAULT);
                        uploadMyPrescription();
                    }
                    catch (Exception e)
                    {
                        Toast.makeText(getActivity(), "Cannot Access Image", Toast.LENGTH_SHORT).show();
                    }

                }
            }
        });
        return v;
    }





    public void onActivityResult(int requestCode,
                                 int resultCode,
                                 Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        switch (requestCode) {
            case CAMERA:
                Bitmap photo = (Bitmap) data.getExtras()
                        .get("data");
                iv_doc.setImageBitmap(photo);
                img_status = 1;
                break;
            case GALLERY:
                Uri selectedImage = data.getData();
                String[] filePathColumn = new String[]{MediaStore.Images.Media.DATA};
                if (selectedImage != null) {
                    Cursor cursor = getActivity().getContentResolver().query(selectedImage,
                            filePathColumn, null, null, null);
                    if (cursor != null) {
                        cursor.moveToFirst();
                        int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
                        String picturePath = cursor.getString(columnIndex);
                        iv_doc.setImageBitmap(BitmapFactory.decodeFile(picturePath));
                        cursor.close();
                    }
                }
                img_status = 1;
                break;
        }
    }

    void getMyPrescription() {
        final ProgressDialog progressDialog = new ProgressDialog(getActivity());
        progressDialog.setTitle("Getting Documents...");
        queue = Volley.newRequestQueue(getActivity());
        queue.getCache().clear();
        StringRequest stringRequest = new StringRequest(Request.Method.POST, Configs.URL_DOCUMENTS_GET,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        log(response);
                        progressDialog.dismiss();
                        try {
                            JSONObject jsonObject = new JSONObject(response);
                            documents = jsonObject.getJSONArray("data");
                            documentViewAdapter = new DocumentViewAdapter(getActivity(), documents);
                            documentListView.setAdapter(documentViewAdapter);
                            return;
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        Toast.makeText(getActivity(), "Error while getting data", Toast.LENGTH_SHORT).show();
                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                progressDialog.dismiss();
                log("Error:" + error.toString());
                Toast.makeText(getActivity(), "Error while getting data", Toast.LENGTH_SHORT).show();
            }
        }) {
            @Override
            protected Map<String, String> getParams() throws AuthFailureError {
                Map data = new HashMap<String, String>();
                data.put("sevarth_no", Configs.sevarthNo);
                data.put("type", "prescription");
                return data;
            }
        };
        progressDialog.show();
        queue.add(stringRequest);
    }

    void uploadMyPrescription() {
        final ProgressDialog progressDialog = new ProgressDialog(getActivity());
        progressDialog.setTitle("Uploading...");
        queue = Volley.newRequestQueue(getActivity());
        queue.getCache().clear();
        StringRequest stringRequest = new StringRequest(Request.Method.POST, Configs.URL_DOCUMENT_UPLOAD,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        log(response);
                        progressDialog.dismiss();
                        if (response.equals("success")) {
                            Toast.makeText(getActivity(), "File Uploaded", Toast.LENGTH_SHORT).show();
                            et_doc_name.setText("");
                            iv_doc.setImageResource(R.drawable.ic_baseline_photo_camera_24);
                            getMyPrescription();
                            return;
                        }
                        Toast.makeText(getActivity(), "Error while uploading", Toast.LENGTH_SHORT).show();
                        progressDialog.dismiss();
                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                progressDialog.dismiss();
                log("Error:" + error.toString());
                Toast.makeText(getActivity(), "Unable to Upload", Toast.LENGTH_SHORT).show();
            }
        }) {
            @Override
            protected Map<String, String> getParams() throws AuthFailureError {
                Map data = new HashMap<String, String>();
                data.put("sevarth_no", Configs.sevarthNo);
                data.put("pic", encodebefore);
                data.put("name", et_doc_name.getText().toString());
                data.put("type", "prescription");
                return data;
            }
        };
        progressDialog.show();
        queue.add(stringRequest);
    }

    void log(String text) {
        Log.d(TAG, "log: " + text);
        System.out.println(TAG + "->log: " + text);
    }

}


class DocumentViewAdapter extends BaseAdapter {
    Context context;
    JSONArray documents;

    DocumentViewAdapter(Context context, JSONArray array) {
        this.context = context;
        this.documents = array;

    }

    @Override
    public int getCount() {
        return documents.length();
    }

    @Override
    public Object getItem(int i) {
        try {
            return documents.get(i);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public long getItemId(int i) {
        return i;
    }

    @Override
    public View getView(int i, View view, ViewGroup viewGroup) {
        view = LayoutInflater.from(context).inflate(R.layout.event_item, null);
        try {
            ((TextView) view.findViewById(R.id.title)).setText(documents.getJSONObject(i).getString("name"));
            ((TextView) view.findViewById(R.id.date)).setText(documents.getJSONObject(i).getString("created_at"));
            Glide.with(context).
                    load(documents.getJSONObject(i).getString("pic")).
                    into(((ImageView) view.findViewById(R.id.icon)));

            if (documents.getJSONObject(i).getString("type") != null)
                ((TextView) view.findViewById(R.id.sub_title)).setText(documents.getJSONObject(i).getString("type"));
        } catch (Exception e) {

        }
        return view;
    }
}