# This regexp is used to partition invoice numbers in maximal numeric and
# non-numeric components, that way "F07_0089" is scanned as ("F", "07", "_",
# "0089").
INVOICE_NUMBER_REGEXP = %r{\D+|\d+}

