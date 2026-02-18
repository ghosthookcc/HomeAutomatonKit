import json

from google.protobuf import descriptor_pb2

SERVICE_NAME_FIELD  = 50001
TIMEOUT_MS_FIELD    = 50002

with open("services.desc", "rb") as f:
    fds = descriptor_pb2.FileDescriptorSet()
    fds.ParseFromString(f.read())

output = []

for proto_file in fds.file:
    if not proto_file.name.startswith("impl"):
        continue

    for service in proto_file.service:
        raw = service.options.SerializeToString()
        unknown = descriptor_pb2.ServiceOptions()
        unknown.ParseFromString(raw)

        service_name = None
        timeout_ms = None

        for field in service.options.ListFields():
            pass  # standard fields only, custom ones won't appear here

        from google.protobuf import descriptor_pool
        from google.protobuf import message_factory
        from google.protobuf import symbol_database

        pool = descriptor_pool.Default()

        from google.protobuf.internal.decoder import _DecodeVarint
        from google.protobuf.internal import decoder

        raw_options = service.options.SerializeToString()

        i = 0
        while i < len(raw_options):
            tag, new_i = _DecodeVarint(raw_options, i)
            field_number = tag >> 3
            wire_type = tag & 0x7
            i = new_i

            if wire_type == 0:  # varint
                val, i = _DecodeVarint(raw_options, i)
                if field_number == TIMEOUT_MS_FIELD:
                    timeout_ms = val
            elif wire_type == 2:  # length delimited (string)
                length, i = _DecodeVarint(raw_options, i)
                val = raw_options[i:i+length].decode("utf-8")
                i += length
                if field_number == SERVICE_NAME_FIELD:
                    service_name = val

        output.append({
            "file": proto_file.name,
            "service": service.name,
            "service_name": service_name,
            "timeout_ms": timeout_ms,
        })

with open("../HomeKit/Dashboard/priv/services/services.json", "w") as f:
    json.dump(output, f, indent=2)
