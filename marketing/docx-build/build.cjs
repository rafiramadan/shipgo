const {
  Document, Packer, Paragraph, TextRun, HeadingLevel, Table, TableRow, TableCell,
  WidthType, BorderStyle, AlignmentType, ShadingType, LevelFormat, convertInchesToTwip,
} = require("docx");

const COLOR_VIOLET = "6355E0";
const COLOR_INK = "211E3E";
const COLOR_SOFT = "6B6E8A";
const COLOR_GOOD = "1F9D5C";
const COLOR_BAD = "C0392B";
const COLOR_LINE = "D9D7EC";

function h1(text) {
  return new Paragraph({ text, heading: HeadingLevel.HEADING_1, spacing: { before: 240, after: 160 } });
}
function h2(num, text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    spacing: { before: 420, after: 140 },
    border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: COLOR_LINE, space: 4 } },
    children: [
      new TextRun({ text: `${num}. `, color: COLOR_VIOLET, bold: true }),
      new TextRun({ text, color: COLOR_INK, bold: true }),
    ],
  });
}
function h3(text) {
  return new Paragraph({ text, heading: HeadingLevel.HEADING_3, spacing: { before: 260, after: 100 } });
}
function eyebrow(text) {
  return new Paragraph({
    spacing: { after: 40 },
    children: [new TextRun({ text: text.toUpperCase(), bold: true, color: COLOR_VIOLET, size: 18, characterSpacing: 20 })],
  });
}
function body(text, opts = {}) {
  return new Paragraph({ spacing: { after: 160 }, children: [new TextRun({ text, color: COLOR_INK, italics: opts.italics || false })] });
}
function quoteLine(text) {
  return new Paragraph({
    spacing: { before: 80, after: 200 },
    border: { left: { style: BorderStyle.SINGLE, size: 18, color: COLOR_VIOLET, space: 8 } },
    indent: { left: 200 },
    children: [new TextRun({ text, bold: true, italics: true, color: COLOR_VIOLET, size: 26 })],
  });
}
function statLine(value, label) {
  return new Paragraph({
    spacing: { after: 60 },
    children: [
      new TextRun({ text: value + "  ", bold: true, color: COLOR_INK, size: 26 }),
      new TextRun({ text: label, color: COLOR_SOFT, size: 20 }),
    ],
  });
}
function pointHeading(text) {
  return new Paragraph({ spacing: { before: 180, after: 40 }, children: [new TextRun({ text, bold: true, color: COLOR_INK })] });
}
function bullet(text) {
  return new Paragraph({ text, bullet: { level: 0 }, spacing: { after: 100 } });
}
function stepBlock(num, title, desc, note) {
  const children = [
    new Paragraph({
      spacing: { before: 200, after: 20 },
      children: [
        new TextRun({ text: num + "  ", bold: true, color: COLOR_VIOLET }),
        new TextRun({ text: title, bold: true, color: COLOR_INK }),
      ],
    }),
    new Paragraph({ spacing: { after: note ? 40 : 120 }, children: [new TextRun({ text: desc, color: COLOR_INK })] }),
  ];
  if (note) {
    children.push(new Paragraph({
      spacing: { after: 120 },
      children: [new TextRun({ text: "→ " + note, italics: true, color: COLOR_SOFT, size: 20 })],
    }));
  }
  return children;
}
function divider() {
  return new Paragraph({
    spacing: { before: 100, after: 100 },
    border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: COLOR_LINE, space: 1 } },
    children: [new TextRun({ text: "" })],
  });
}

function compareRow(aspect, before, now, isHeader = false) {
  const cellStyle = (text, opts = {}) => new TableCell({
    width: { size: opts.w, type: WidthType.DXA },
    shading: isHeader ? { type: ShadingType.CLEAR, fill: "F1EFFC" } : undefined,
    margins: { top: 100, bottom: 100, left: 120, right: 120 },
    children: [new Paragraph({
      children: [new TextRun({
        text: (opts.prefix || "") + text,
        bold: isHeader,
        color: isHeader ? COLOR_VIOLET : (opts.color || COLOR_INK),
        size: isHeader ? 20 : 20,
      })],
    })],
  });
  return new TableRow({
    children: [
      cellStyle(aspect, { w: 2200 }),
      cellStyle(before, { w: 3400, prefix: isHeader ? "" : "✕ ", color: COLOR_BAD }),
      cellStyle(now, { w: 3800, prefix: isHeader ? "" : "✓ ", color: COLOR_GOOD }),
    ],
  });
}

const doc = new Document({
  numbering: { config: [{ reference: "bullets", levels: [{ level: 0, format: LevelFormat.BULLET, text: "•", alignment: AlignmentType.LEFT }] }] },
  sections: [{
    properties: { page: { size: { width: 12240, height: 15840 }, margin: { top: 1000, bottom: 1000, left: 1100, right: 1100 } } },
    children: [
      new Paragraph({ text: "ShipGo", heading: HeadingLevel.TITLE, spacing: { after: 40 } }),
      new Paragraph({
        spacing: { after: 60 },
        children: [new TextRun({ text: "Transport Management System untuk Setiap Mil Distribusi", color: COLOR_SOFT, size: 24 })],
      }),
      new Paragraph({
        spacing: { after: 300 },
        children: [new TextRun({ text: "Konten Landing Page", italics: true, color: COLOR_SOFT, size: 20 })],
      }),

      // 1. NAVBAR
      h2("1", "Navbar"),
      body("Logo: ShipGo"),
      new Paragraph({
        spacing: { after: 160 },
        children: [new TextRun({ text: "Menu: ", bold: true }), new TextRun({ text: "Order Management  ·  Cakupan Area  ·  Perbandingan" })],
      }),

      // 2. HERO
      h2("2", "Hero"),
      eyebrow("New TMS · Menggantikan DOTS"),
      new Paragraph({
        spacing: { after: 160 },
        children: [new TextRun({ text: "Rute boleh berpindah tangan. Datanya tidak pernah putus.", bold: true, size: 32, color: COLOR_INK })],
      }),
      body("ShipGo adalah Transport Management System untuk setiap mil distribusi — menyatukan Planning, Assignment, dan Tracking dalam satu alur Shipment, dari pengiriman pertama sampai terkirim, termasuk saat transit lewat Depo atau Distribution Center lain."),
      quoteLine("With ShipGo, we start — let's Go."),

      // 3. DOTS RETROSPECTIVE & MILESTONE
      h2("3", "DOTS Retrospective & Milestone"),
      eyebrow("Retrospective"),
      h3("DOTS berhenti di batas satu gudang"),
      body("DOTS dibangun untuk pengiriman yang sederhana: satu DC, satu driver, satu rute langsung. Begitu operasional bertambah kompleks — Depo, transit, retur, biaya per leg — sistem lama tidak punya tempat untuk mencatatnya."),

      pointHeading("Akses — User terkunci ke satu Distribution Center"),
      bullet("Satu akun tidak bisa di-extend ke Depo lain, meski satu orang menangani beberapa lokasi."),
      pointHeading("Fleet — Fleet menempel ke satu Driver"),
      bullet("Kendaraan tidak bisa dipakai bersama antar driver dalam satu Shipping Point."),
      pointHeading("Coverage — Area kecamatan tidak terdefinisi di sistem"),
      bullet("Cakupan wilayah tiap DC hanya diketahui secara informal, tidak tercatat di platform."),
      pointHeading("Rute — Hanya memfasilitasi pengiriman Direct"),
      bullet("Transit lewat Depo atau DC lain terjadi di lapangan, tapi tidak tercatat di sistem."),

      divider(),
      eyebrow("Milestone"),
      h3("Apa yang sudah bergerak lewat ShipGo"),
      body("Angka langsung dari data Planning hari ini — bukan proyeksi.", { italics: true }),
      statLine("283", "DO Outstanding direncanakan"),
      statLine("5.842", "SKU terlacak"),
      statLine("1.284", "Shipping unit"),
      statLine("124.920", "Pcs terkirim"),
      statLine("28", "Area tercakup"),

      // 4. SHOWCASE
      h2("4", "ShipGo Highlight Feature (Showcase)"),
      body("Dua perubahan paling terasa dari DOTS, ditampilkan sesuai tampilan asli di dalam produk."),

      eyebrow("Core Flow"),
      h3("Order Management — Satu alur, dari draft sampai selesai"),
      body("Order Management di ShipGo dipecah menjadi empat tahap yang saling terhubung — bukan satu langkah assign yang langsung final seperti di DOTS."),
      ...stepBlock("01 · Planning", "Susun draft Shipment dari kumpulan Delivery Order",
        "Koordinator melihat seluruh dokumen outstanding dalam satu ringkasan — total SKU, shipping unit, dan area yang tercakup — sebelum mengelompokkannya menjadi draft Shipment.",
        "Sebelumnya: assignment langsung per Delivery Order, tanpa tahap draft."),
      ...stepBlock("02 · Assignment", "Pilih Driver dan Fleet untuk tiap Shipment",
        "Assignment tidak berhenti di driver saja — fleet dipilih secara eksplisit, dan satu Shipment bisa menggabungkan tugas Drop (pengiriman) dan Pick Up (retur) dalam satu perjalanan.",
        "Sebelumnya: hanya assign ke driver; retur ditangani di menu terpisah."),
      ...stepBlock("03 · Tracking", "Dua lapis status, satu pandangan",
        "Order Status memberi gambaran umum untuk pelaporan, Order Stage memberi detail operasional — termasuk saat dokumen sedang transit dan menunggu re-assignment di Depo atau DC lain.",
        "Sebelumnya: satu status teknis, tidak membedakan level pelaporan dan operasional."),
      ...stepBlock("04 · Review", "Evaluasi setelah Shipment selesai",
        "Setiap Shipment yang selesai masuk ke tahap Review, sebagai titik pemeriksaan sebelum data ditutup dan dijadikan dasar perbaikan proses pengiriman berikutnya.", null),

      divider(),
      eyebrow("Location & Coverage Area"),
      h3("Coverage Area — Cakupan area terbentuk sendiri dari data rute"),
      body("Tidak perlu menggambar area cakupan secara manual. Cukup petakan setiap Kecamatan ke Staging Bay yang menanganinya, dan coverage area untuk Shipping Point tersebut ter-generate otomatis."),
      body("Setiap Shipping Point punya dua tingkat: Distribution Center sebagai gudang utama, dan Depo / Cross-Dock sebagai perpanjangan area layanan. Satu Staging Bay bisa di-extend ke Depo lain saat kapasitas DC utama penuh."),
      new Paragraph({
        spacing: { after: 160 },
        children: [new TextRun({ text: "Route Code dan Kecamatan pada tiap Staging Bay menjadi baseline untuk auto-generate coverage area — akurasinya langsung memengaruhi Route Type mana yang terpilih otomatis saat Planning.", italics: true, color: COLOR_SOFT, size: 20 })],
      }),

      // 5. ADDED VALUE
      h2("5", "ShipGo Added Value (Point)"),
      body("Perubahan-perubahan kecil yang terasa besar — masing-masing menghapus satu langkah manual yang tidak pernah punya jawaban di DOTS."),
      pointHeading("1. Transporter Config terpusat"),
      bullet("Mapping shipment type dan shipping type diatur sekali di level Transporter, bukan diulang di tiap Fleet."),
      pointHeading("2. Fleet sebagai resource bersama"),
      bullet("Kendaraan tidak lagi menempel ke satu Driver — dikelola dan dipilih per Shipping Point."),
      pointHeading("3. Shipment Cost & approval"),
      bullet("Biaya tercatat per leg pengiriman, mengikuti alur persetujuan Driver → Koordinator → Admin Kasir → BCR di dalam sistem."),
      pointHeading("4. Retur terintegrasi"),
      bullet("Pick up retur menjadi order type di dalam Shipment yang sama, bukan menu terpisah berbasis customer."),
      pointHeading("5. Login lebih akuntabel"),
      bullet("Email & password atau Microsoft Account — akun tidak lagi mudah dibagi bebas antar pengguna."),
      pointHeading("6. Master data reason berbahasa Indonesia"),
      bullet("Dikelola langsung dari menu aplikasi, lengkap dengan status aktif/nonaktif — tidak lagi bergantung pada tim engineering."),

      // 6. COMPARISON
      h2("6", "Comparison"),
      body("Ringkasan dari Change Impact Assessment TMS Mid & Last Mile — setiap baris adalah pergeseran nyata dalam cara kerja, bukan sekadar tampilan baru."),
      new Table({
        width: { size: 9400, type: WidthType.DXA },
        columnWidths: [2200, 3400, 3800],
        rows: [
          compareRow("Aspek", "DOTS — Sebelum", "ShipGo — Sekarang", true),
          compareRow("Struktur Akses", "Terkunci ke satu Distribution Center", "Berbasis Shipping Point — satu akun mencakup DC + Depo"),
          compareRow("Login", "Username & password, mudah dibagi", "Email + password atau Microsoft SSO, akuntabel per user"),
          compareRow("Transporter & Fleet", "Setup manual per Fleet, Fleet menempel ke Driver", "Transporter Config terpusat, Fleet jadi resource bersama"),
          compareRow("Coverage Area", "Tidak terdefinisi di sistem", "Auto-generate dari mapping Kecamatan ↔ Staging Bay"),
          compareRow("Planning", "Assign langsung per Delivery Order ke Driver", "Draft Shipment dulu, pilih Driver + Fleet + Route Type"),
          compareRow("Rute Pengiriman", "Hanya Direct", "Direct, Transit Crossdock/Depo, Transit DC"),
          compareRow("Status Pengiriman", "Satu lapis, teknis", "Order Status (umum) + Order Stage (detail operasional)"),
          compareRow("Shipment Cost", "Direkap manual di luar sistem", "Tercatat per leg dengan approval workflow di sistem"),
          compareRow("Retur", "Menu terpisah, level customer", "Order type Pick Up, terintegrasi dalam Shipment"),
        ],
      }),

      // 7. CTA
      h2("7", "CTA"),
      quoteLine("With ShipGo, we start — let's Go."),
      body("Satu alur Shipment, dari Planning sampai Review — dibangun untuk setiap mil distribusi yang dijalankan PT Parama Global Inspira."),

      // 8. FOOTER
      h2("8", "Footer"),
      new Paragraph({
        spacing: { after: 100 },
        children: [new TextRun({ text: "ShipGo", bold: true }), new TextRun({ text: "  ·  Transport Management System untuk setiap mil distribusi", color: COLOR_SOFT })],
      }),
      pointHeading("Produk"),
      bullet("Order Management"),
      bullet("Cakupan Area"),
      bullet("Perbandingan"),
      pointHeading("Perusahaan"),
      bullet("PT Parama Global Inspira"),
      new Paragraph({
        spacing: { before: 200 },
        border: { top: { style: BorderStyle.SINGLE, size: 4, color: COLOR_LINE, space: 8 } },
        children: [new TextRun({ text: "Dikembangkan untuk lingkup operasional PT Parama Global Inspira", size: 18, color: COLOR_SOFT })],
      }),
    ],
  }],
});

Packer.toBuffer(doc).then((buf) => {
  require("fs").writeFileSync("ShipGo-Landing-Page-Content.docx", buf);
  console.log("written");
});
