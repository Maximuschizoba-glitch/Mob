<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('happenings', function (Blueprint $table) {
            $table->text('hidden_reason')->nullable()->after('status');
            $table->foreignId('hidden_by')->nullable()->after('hidden_reason')->constrained('users')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('happenings', function (Blueprint $table) {
            $table->dropForeign(['hidden_by']);
            $table->dropColumn(['hidden_reason', 'hidden_by']);
        });
    }
};
