<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Api\V1\BaseController;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LogController extends BaseController
{
    /**
     * Return the last N lines from storage/logs/laravel.log (or today's dated log).
     *
     * Query params:
     *   lines  – how many tail lines to return (default 100, max 500)
     *   level  – filter by level keyword: ERROR, WARNING, CRITICAL, etc. (optional)
     */
    public function tail(Request $request): JsonResponse
    {
        $lines = min((int) $request->query('lines', 100), 500);
        $level = strtoupper((string) $request->query('level', ''));

        // Resolve log file — prefer today's dated file, fall back to laravel.log
        $logDir  = storage_path('logs');
        $dated   = $logDir . '/laravel-' . now()->format('Y-m-d') . '.log';
        $default = $logDir . '/laravel.log';

        if (file_exists($dated)) {
            $logFile = $dated;
        } elseif (file_exists($default)) {
            $logFile = $default;
        } else {
            // List whatever .log files do exist so we can debug
            $found = glob($logDir . '/*.log') ?: [];
            return $this->errorResponse(
                'No log file found. Looked for: ' . basename($dated) . ', laravel.log. '
                . 'Files present: ' . implode(', ', array_map('basename', $found)),
                404
            );
        }

        // Read last N lines efficiently without loading the whole file
        $allLines = $this->tailFile($logFile, $lines * 4); // grab extra for filtering

        if ($level !== '') {
            $allLines = array_values(
                array_filter($allLines, fn ($l) => str_contains(strtoupper($l), $level))
            );
        }

        // Return the last $lines entries after filtering
        $allLines = array_slice($allLines, -$lines);

        return $this->successResponse([
            'file'       => basename($logFile),
            'lines'      => count($allLines),
            'level'      => $level ?: 'all',
            'log'        => implode("\n", $allLines),
        ], 'Log retrieved successfully');
    }

    /**
     * Read the last $n lines from a file without loading it all into memory.
     *
     * @return string[]
     */
    private function tailFile(string $path, int $n): array
    {
        $fp   = fopen($path, 'rb');
        $size = filesize($path);

        if ($size === 0 || $fp === false) {
            return [];
        }

        $chunkSize = 4096;
        $buffer    = '';
        $pos       = $size;
        $found     = 0;

        while ($pos > 0 && $found <= $n) {
            $read  = min($chunkSize, $pos);
            $pos  -= $read;
            fseek($fp, $pos);
            $buffer = fread($fp, $read) . $buffer;
            $found  = substr_count($buffer, "\n");
        }

        fclose($fp);

        $lines = explode("\n", $buffer);

        // Drop trailing empty line from final newline
        if (end($lines) === '') {
            array_pop($lines);
        }

        return array_slice($lines, -$n);
    }
}
