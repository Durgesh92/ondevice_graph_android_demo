package com.durgesh.ondevice_graph_asr;

import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import android.Manifest;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.TimeUnit;

import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class MainActivity extends AppCompatActivity {

    EditText lm_data;
    Button buildModel;
    String folder_main = "durgesh_ai";
    String ip = "https://87b4-103-51-136-54.in.ngrok.io";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        lm_data = findViewById(R.id.editTextlm);
        buildModel = findViewById(R.id.buildModel);
        if(!checkWritePermission()){
            requestWritePermission();
        }
        if (!isExternalStorageAvailable() || isExternalStorageReadOnly()) {
            buildModel.setEnabled(false);
        }
        buildModel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                dumpDataToFile();
                UploadAsyncTask uploadAsyncTask = new UploadAsyncTask(MainActivity.this);
                uploadAsyncTask.execute();
            }
        });

    }

    private static boolean isExternalStorageReadOnly() {
        String extStorageState = Environment.getExternalStorageState();
        if (Environment.MEDIA_MOUNTED_READ_ONLY.equals(extStorageState)) {
            return true;
        }
        return false;
    }

    private static boolean isExternalStorageAvailable() {
        String extStorageState = Environment.getExternalStorageState();
        if (Environment.MEDIA_MOUNTED.equals(extStorageState)) {
            return true;
        }
        return false;
    }

    private boolean checkWritePermission() {
        int result1 = ContextCompat.checkSelfPermission(getApplicationContext(), WRITE_EXTERNAL_STORAGE);
        int result2 = ContextCompat.checkSelfPermission(getApplicationContext(), Manifest.permission.RECORD_AUDIO);
        return result1 == PackageManager.PERMISSION_GRANTED && result2 == PackageManager.PERMISSION_GRANTED ;
    }

    private void requestWritePermission() {
        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.RECORD_AUDIO,Manifest.permission.MODIFY_AUDIO_SETTINGS,WRITE_EXTERNAL_STORAGE},1);
    }

    void dumpDataToFile(){
        String data = lm_data.getText().toString();
        String[] sentences = data.split("\n");
        Log.e("Durgesh","sentences.length : "+ sentences.length);
        writeFileOnInternalStorage(MainActivity.this,"corpus.txt",data);
    }

    public void writeFileOnInternalStorage(Context mcoContext, String sFileName, String sBody){
        File dir = new File(String.valueOf(getExternalFilesDir(folder_main)));
        Log.e("Durgesh",String.valueOf(getExternalFilesDir(folder_main)));
        if(!dir.exists()){
            dir.mkdir();
        }
        try {
            File myExternalFile = new File(getExternalFilesDir(folder_main), sFileName);
            FileOutputStream fos = new FileOutputStream(myExternalFile);
            fos.write(sBody.getBytes());
            fos.close();
        } catch (Exception e){
            e.printStackTrace();
        }
    }

    public boolean saveFile(Context context, String mytext){
        Log.i("TESTE", "SAVE");
        try {
            FileOutputStream fos = context.openFileOutput("file_name"+".txt",Context.MODE_PRIVATE);
            Writer out = new OutputStreamWriter(fos);
            out.write(mytext);
            out.close();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }


    public String doUpload(String filename){
        String urlServer = ip+"/upload";
        OkHttpClient.Builder builder = new OkHttpClient.Builder();
        builder.connectTimeout(30, TimeUnit.SECONDS);
        builder.readTimeout(30, TimeUnit.SECONDS);
        File file = new File(filename);
        RequestBody requestBody = new MultipartBody.Builder()
                .setType(MultipartBody.FORM)
                .addFormDataPart("file", file.getName(),
                        RequestBody.create(MediaType.parse("application/octet-stream"), file))
                .build();
        Request requestBuilder = new Request.Builder()
                .url(urlServer)
                .post(requestBody)
                .build();
        OkHttpClient client = builder.build();
        try {
            Response response = client.newCall(requestBuilder).execute();
            String ret = response.body().string();
            Log.e("Durgesh","response.body().string() : "+ret);
            JSONObject jObject = new JSONObject(ret);
            String session = jObject.getString("path");
            return session;
        } catch (IOException e) {
            e.printStackTrace();
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return null;
    }

    private class UploadAsyncTask extends AsyncTask<Void, String, String> {

        private Context context;
        private ProgressDialog progressDialog;
        private String rett;

        public UploadAsyncTask(Context context) {
            this.context = context;
        }

        @Override
        protected void onPreExecute() {
            progressDialog = ProgressDialog.show(context, "Please wait...", "downloading model");
        }

        @Override
        protected String doInBackground(Void... params) {
            String object = null;
            String session = doUpload(Environment.getExternalStorageDirectory().getPath() + "/" +folder_main+"/corpus.txt");

            if (session.contains("error")){
                rett = "error";
                return "error";
            }else {
                String download_url = ip+"/download/"+session;

                final String downloadPath = Environment.getExternalStorageDirectory() + "/"+folder_main+"/";
                final File file = new File(downloadPath);
                final File outputFile = new File(file, "hotword.pmdl");
                try {
                    if (outputFile.exists()){
                        outputFile.delete();
                    }

                    URL url = new URL(download_url);
                    HttpURLConnection c = (HttpURLConnection) url.openConnection();
                    c.setDoOutput(true);
                    c.connect();

                    file.mkdirs();
                    FileOutputStream fos = new FileOutputStream(outputFile);
                    InputStream is = c.getInputStream();

                    byte[] buffer = new byte[2048];
                    int len1 = 0;
                    while ((len1 = is.read(buffer)) != -1) {
                        fos.write(buffer, 0, len1);
                    }
                    fos.close();
                    is.close();
                    Log.e("Durgesh","File Downloaded");
                    rett = "ok";
                    return "ok";
                }
                catch (Exception e) {
                    Log.e("Durgesh", "Caught unexpected IOException: " + e, e);
                    rett = "error";
                    return "error";
                }
            }
        }

        @Override
        protected void onPostExecute(String s) {
            super.onPostExecute(s);
            if (progressDialog != null && progressDialog.isShowing()) {
                progressDialog.dismiss();
            }
        }
    }
}