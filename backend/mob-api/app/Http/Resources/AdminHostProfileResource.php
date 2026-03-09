<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;

class AdminHostProfileResource extends HostProfileResource
{
    public function toArray(Request $request): array
    {
        return array_merge(parent::toArray($request), [
            'id' => $this->id,
            'verification_document_url' => $this->verification_document_url,
            'admin_notes' => $this->admin_notes,
        ]);
    }
}
