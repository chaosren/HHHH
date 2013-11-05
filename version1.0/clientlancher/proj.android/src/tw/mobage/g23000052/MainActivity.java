package tw.mobage.g23000052;

import org.DeNA.DHLJ.DaHuaLongJiang;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;

public class MainActivity extends Activity {	
	private static MainActivity mActivity;
	
	protected void onCreate(Bundle savedInstanceState) {
		Log.d("init", "@@ MainActivity.onCreate()");
		super.onCreate(savedInstanceState);
		mActivity = this;
		
		//ÍøÂçÅÐ¶Ï
		if (!isNetworkAvailable())
		{
			String textStringTitle = this.getResources().getString(R.string.dialog_sdcard_title);
			String textStringContent = this.getResources().getString(R.string.dialog_network_notexist);
			AlertDialog alertDialog = new AlertDialog.Builder(this).create();
			alertDialog.setTitle(textStringTitle);
			alertDialog.setMessage(textStringContent);
			alertDialog.setIcon(R.drawable.dhlj_icon);
			alertDialog.setCancelable(false);
			alertDialog.setButton(this.getResources().getString(R.string.dialog_sdcard_exit), new DialogInterface.OnClickListener() {
	            public void onClick(DialogInterface dialog, int whichButton) {
	            		mActivity.finish();
	                  }
	                });

			alertDialog.show();
			return;
		}
		
		//T¿¨ÅÐ¶Ï
		if (!isSDCardCanUse())
		{
			String textStringTitle = this.getResources().getString(R.string.dialog_sdcard_title);
			String textStringContent = this.getResources().getString(R.string.dialog_sdcard_notexist);
			AlertDialog alertDialog = new AlertDialog.Builder(this).create();
			alertDialog.setTitle(textStringTitle);
			alertDialog.setMessage(textStringContent);
			alertDialog.setIcon(R.drawable.dhlj_icon);
			alertDialog.setCancelable(false);
			alertDialog.setButton(this.getResources().getString(R.string.dialog_sdcard_exit), new DialogInterface.OnClickListener() {
	            public void onClick(DialogInterface dialog, int whichButton) {
	            		mActivity.finish();
	                  }
	                });

			alertDialog.show();
			return;
		}
		
		startDaHuaLongJiang();
	}
	
	public static void onExit()
	{
//		android.os.Process.killProcess(pid);
		if(mActivity != null) {
			mActivity.finish();
			mActivity = null;
			System.exit(0);
		}
	}
	
	
	public void startDaHuaLongJiang()
	{
		Intent i = new Intent(this, DaHuaLongJiang.class);
		i.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		i.addFlags(Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED);
		i.addFlags(Intent.FLAG_ACTIVITY_PREVIOUS_IS_TOP);
		i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		startActivity(i);
		this.finish();
	}
	
	public boolean isNetworkAvailable() {
		ConnectivityManager conMgr =  (ConnectivityManager)getSystemService(Context.CONNECTIVITY_SERVICE);

		Log.d("init",conMgr.getNetworkInfo(0).getState()+ ";;;" + conMgr.getNetworkInfo(1).getState());
		
		if ( conMgr.getNetworkInfo(0).getState() == NetworkInfo.State.CONNECTED 
		    ||  conMgr.getNetworkInfo(1).getState() == NetworkInfo.State.CONNECTED  ) {
			Log.d("init", "@@ CONNECTED.return true;");
		    return true;
		}
		return false;
	}
	
	public boolean isSDCardCanUse()
	{
		String strState = Environment.getExternalStorageState();

		if (Environment.MEDIA_MOUNTED.equals(strState))
		{
			return true;
		}

		return false;
	}

}
