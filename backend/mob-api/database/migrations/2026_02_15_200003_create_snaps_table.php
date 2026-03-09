<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{



    public function up(): void
    {
        Schema::create('snaps', function (Blueprint $table) {
            $table->id();
            $table->string('uuid')->unique();
            $table->foreignId('happening_id')->constrained('happenings')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('media_url');
            $table->string('media_type');
            $table->string('thumbnail_url')->nullable();
            $table->timestamp('expires_at');
            $table->timestamps();
            $table->softDeletes();
        });
    }




    public function down(): void
    {
        Schema::dropIfExists('snaps');
    }
};
