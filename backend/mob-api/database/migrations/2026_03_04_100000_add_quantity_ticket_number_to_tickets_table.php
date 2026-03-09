<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('tickets', function (Blueprint $table) {
            $table->unsignedInteger('quantity')->default(1)->after('uuid');
            $table->string('ticket_number')->nullable()->after('quantity');



            $table->dropUnique(['payment_reference']);
            $table->index('payment_reference');
        });
    }

    public function down(): void
    {
        Schema::table('tickets', function (Blueprint $table) {
            $table->dropColumn(['quantity', 'ticket_number']);

            $table->dropIndex(['payment_reference']);
            $table->unique('payment_reference');
        });
    }
};
