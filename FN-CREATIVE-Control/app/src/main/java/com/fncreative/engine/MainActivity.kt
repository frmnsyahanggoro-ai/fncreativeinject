package com.fncreative.engine

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import com.fncreative.engine.databinding.ActivityMainBinding
import java.util.concurrent.Executors

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private val pool = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.btnEnableRotation.setOnClickListener {
            runSu("touch /data/props/.auto_rotate_profile") { toast(it); refreshDashboard() }
        }
        binding.btnDisableRotation.setOnClickListener {
            runSu("rm -f /data/props/.auto_rotate_profile") { toast(it); refreshDashboard() }
        }
        binding.btnUpdateDatabase.setOnClickListener {
            runSu("sh /data/props/update_database.sh") {
                showDialog(getString(R.string.result_title), it)
                refreshDashboard()
            }
        }
        binding.btnDeviceInfo.setOnClickListener {
            runSu(
                "echo model=\$(getprop ro.product.model); " +
                    "echo brand=\$(getprop ro.product.brand); " +
                    "echo board=\$(getprop ro.product.board); " +
                    "echo soc=\$(getprop ro.board.platform); " +
                    "echo patch=\$(getprop ro.build.version.security_patch)"
            ) { showDialog(getString(R.string.device_info_title), it) }
        }
        binding.btnViewLog.setOnClickListener {
            runSu("head -n 400 /data/props/autoprops.log 2>/dev/null || echo '(empty log)'") {
                showDialog(getString(R.string.log_title), it)
            }
        }
        binding.btnRefreshDashboard.setOnClickListener { refreshDashboard() }
        binding.btnCliMenu.setOnClickListener { runToolkitMenu() }
        binding.btnSaveManual.setOnClickListener { saveManual() }
    }

    override fun onResume() {
        super.onResume()
        refreshDashboard()
    }

    private fun refreshDashboard() {
        val cmd =
            "printf '%s\\n' " +
                "\"rotation: \$(test -f /data/props/.auto_rotate_profile && echo on || echo off)\" " +
                "\"safe_mode: \$(test -f /cache/.disable_autoprops && echo yes || echo no)\" " +
                "\"manual_profile: \$(test -f /data/props/.manual_profile && echo set || echo none)\" " +
                "\"engine_log_last: \$(tail -n 1 /data/props/autoprops.log 2>/dev/null || echo n/a)\""
        runSu(cmd) { text ->
            binding.tvDashboardStatus.text = text.ifBlank { getString(R.string.dashboard_empty) }
        }
    }

    private fun runToolkitMenu() {
        toast(getString(R.string.menu_toast))
        pool.execute {
            try {
                Runtime.getRuntime().exec(arrayOf("su", "-c", "sh /data/props/menu.sh"))
            } catch (_: Exception) {
                mainHandler.post { toast(getString(R.string.menu_failed)) }
            }
        }
    }

    private fun saveManual() {
        val m = binding.etManualProfile.text.toString().trim()
        if (m.isEmpty()) {
            toast(getString(R.string.manual_empty))
            return
        }
        if (!m.matches(Regex("^[A-Za-z0-9 _.,+\\-]+$"))) {
            toast(getString(R.string.manual_bad_chars))
            return
        }
        val escaped = m.replace("'", "'\\''")
        runSu("echo '$escaped' > /data/props/.manual_profile") {
            toast(getString(R.string.manual_saved))
            refreshDashboard()
        }
    }

    private fun runSu(cmd: String, onResult: (String) -> Unit) {
        pool.execute {
            val text = try {
                val p = Runtime.getRuntime().exec(arrayOf("su", "-c", cmd))
                val out = p.inputStream.bufferedReader().use { it.readText() }
                val err = p.errorStream.bufferedReader().use { it.readText() }
                val code = p.waitFor()
                (out + err).trim().ifEmpty { "exit $code" }
            } catch (e: Exception) {
                e.message ?: e.toString()
            }
            mainHandler.post { onResult(text) }
        }
    }

    private fun toast(s: String) =
        Toast.makeText(this, s, Toast.LENGTH_SHORT).show()

    private fun showDialog(title: String, msg: String) {
        AlertDialog.Builder(this)
            .setTitle(title)
            .setMessage(msg)
            .setPositiveButton(android.R.string.ok, null)
            .show()
    }

    override fun onDestroy() {
        pool.shutdownNow()
        super.onDestroy()
    }
}
