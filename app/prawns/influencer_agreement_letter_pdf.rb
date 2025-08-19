# frozen_string_literal: true

require "open-uri"

class InfluencerAgreementLetterPdf < Prawn::Document
  def initialize(media_plan, scope_of_work, influencer, view)
    super(top_margin: 70, page_size: "A4")

    @media_plan = media_plan
    @scope_of_work = scope_of_work
    @influencer = influencer
    @view = view

    font 'Times-Roman'
    header
    move_down 15
    font_size 12
    first_party
    move_down 15
    second_party
    move_down 15
    chapter1
    move_down 15
    chapter2
    move_down 15
    chapter3
    move_down 15
    chapter4
    move_down 15
    chapter5
    sign_place_holder
  end

  def header
    logo
    contact_info
    contract_number
  end

  def first_party
    text "Kami yang bertandatangan di bawah ini :", align: :left
    move_down 5

    data = []

    data << ["Nama", ": SABRINA FARHANA"]
    data << ["Jabatan", ": Direktur"]
    data << ["Alamat", ": Recapital Building 1st Floor, Jl. Adityawarman no.55, Jakarta Selatan, Daerah Khusus Ibukota Jakarta 12160"]
    data << ["Nomor Handphone", ": 6221-7226825"]

    table(data,
      width: 500,
      column_widths: { 0 => 150 },
      cell_style: { size: 12, inline_format: true, align: :left, valign: :center, border_width: 0 }
    )

    move_down 10
    text "Yang bertindak untuk dan atas nama <b>PT. Tekno Solusi Mediarumu</b> yang selanjutnya disebut sebagai <b>PIHAK PERTAMA</b>, dan", inline_format: true
  end

  def second_party
    data = []

    data << ["Nama", ": #{@influencer.name}"]
    data << ["Alamat", ": #{@influencer.address}"]
    data << ["NIK", ": #{@influencer.no_ktp}"]
    data << ["NPWP", ": #{@influencer.no_npwp}"]
    data << ["Nomor Handphone", ": #{@influencer.phone_number}"]
    data << ["Email", ": #{@influencer.email}"]

    table(data,
      width: 500,
      column_widths: { 0 => 150 },
      cell_style: { size: 12, inline_format: true, align: :left, valign: :center, border_width: 0 }
    )

    move_down 10
    text "Yang bertindak sebagai influencer atas Campaign <b>#{@media_plan.campaign.name}</b> yang selanjutnya disebut sebagai <b>PIHAK KEDUA</b>.", inline_format: true
    move_down 5
    text "Kedua belah pihak sepakat untuk mengikatkan diri dalam perjanjian kerja untuk waktu tertentu (kontrak) dengan syarat dan ketentuan sebagai berikut:"
  end

  def contract_number
    bounding_box([100, 700], width: 350, height: 100) do
      text "SURAT PERJANJIAN KERJA", align: :center, size: 14, style: :bold
      move_down 5
      text "UNTUK WAKTU TERTENTU", align: :center, size: 14, style: :bold
      move_down 5
      text "(KONTRAK)", align: :center, size: 14, style: :bold
      move_down 5
      text "SPK/TSM/#{Date.today.month}/#{@scope_of_work.id}", align: :center, size: 14, style: :bold
    end
  end

  def chapter1
    text "Pasal 1", align: :center, style: :bold
    move_down 5
    text "PIHAK PERTAMA,", style: :bold

    data = []
    data << ["1.", "Menerima dan mempekerjakan PIHAK KEDUA sebagai Influencer dengan masa kontrak yang telah disepakati."]
    data << ["2.", "Mengirimkan semua informasi tentang brief campaign yang akan dilaksanakan kepada PIHAK KEDUA."]
    data << ["3.", "Memberikan panduan kepada PIHAK KEDUA untuk membuat konten yang akan diposting."]
    data << ["4.", "Membayar kompensasi kerjasama sebesar <b>IDR #{@view.number_with_delimiter(@scope_of_work.total)}</b>"]
    data << ["5.", "Melaksanakan pembayaran yang dimaksud pada Pasal 1 Ayat 4 kepada Pihak Kedua dengan cara sebagai berikut:"]

    table(data,
      width: 500,
      column_widths: { 0 => 18 },
      cell_style: { size: 12, inline_format: true, align: :left, valign: :center, border_width: 0 }
    )

    sentences = []
    sentences << ["a.", "Pembayaran pekerjaan akan dilakukan setelah pihak kedua menyerahkan invoice dan surat perjanjian kerja (SPK) yang sudah ditandatangani beserta KTP/Personal ID, dan NPWP (jika ada) dan dikembalikan paling lambat 4 hari sebelum tanggal pembayaran."]
    if @scope_of_work.agreement_payment_terms_note.blank?
      sentences << ["b.", "Pembayaran pelunasan akan dilakukan pada H-2 (50% Down Payment) dan H+7 setelah PIHAK KEDUA menyelesaikan pekerjaan dan mengirimkan invoice kepada PIHAK PERTAMA."]
    else
      sentences << ["b.", @scope_of_work.agreement_payment_terms_note]
    end
    sentences << ["c.", "PIHAK KEDUA akan mengirimkan bukti laporan kepada PIHAK PERTAMA setelah campaign selesai berjalan."]

    span(450, position: :center) do
      table(sentences,
        width: 450,
        column_widths: { 0 => 18 },
        cell_style: { size: 12, inline_format: true, align: :left, valign: :center, border_width: 0 }
      )
    end
  end

  def chapter2
    text "Pasal 2", align: :center, style: :bold
    move_down 5
    text "PIHAK KEDUA,", style: :bold

    data = []
    data << ["1.", "Bersedia menerima dan melaksanakan tugas dan tanggung jawab tersebut serta tugas-tugas lain yang diberikan PIHAK PERTAMA dengan sebaik-baiknya dan rasa tanggung-jawab."]
    data << ["2.", "Bersedia menyimpan dan menjaga kerahasiaan baik dokumen maupun informasi apapun milik PIHAK PERTAMA dan tidak dibenarkan memberikan dokumen atau informasi yang diketahui baik secara lisan maupun tertulis kepada pihak lain, baik sebelum, saat dan setelah selesainya periode campaign maupun kerja sama ini."]
    data << ["3.", "Wajib mempublikasikan postingan campaign di social media PIHAK KEDUA dengan pembagian sebagai berikut:"]

    table(data,
      width: 500,
      column_widths: { 0 => 18 },
      cell_style: { size: 12, inline_format: true, align: :left, valign: :center, border_width: 0 }
    )

    notes = []
    @scope_of_work.scope_of_work_items.each do |item|
      if item.subtotal.to_i != 0
        note = "#{item.quantity}x #{item.name.humanize}"
        notes << ["-", note]
      end
    end

    span(450, position: :center) do
      table(notes,
        width: 450,
        column_widths: { 0 => 18 },
        cell_style: { size: 12, inline_format: true, align: :left, valign: :center, border_width: 0 }
      )
    end

    data1 = []
    data1 << ["4.", "Menyelesaikan tugas berdasarkan tenggat waktu yang telah disepakati bersama."]
    data1 << ["5.", "Selama kontrak kerja berlangsung tidak diperkenankan untuk memutuskan hubungan kerja secara sepihak"]
    data1 << ["6.", "Wajib menyerahkan invoice dan surat perjanjian kerja (SPK) yang sudah ditandatangani beserta KTP/Personal ID, dan NPWP (jika ada) sebagai syarat pembayaran maksimal #{@scope_of_work.agreement_maximum_payment_day || 10 } hari sebelum tanggal pembayaran yang tertera di Pasal 1."]

    table(data1,
      width: 500,
      column_widths: { 0 => 18 },
      cell_style: { size: 12, inline_format: true, align: :left, valign: :center, border_width: 0 }
    )
  end

  def chapter3
    text "Pasal 3", align: :center, style: :bold
    move_down 5
    text "Selama Kontrak Kerja berlangsung, PIHAK PERTAMA dapat memberikan sanksi berupa kompensasi tidak dibayarkan kepada PIHAK KEDUA apabila ternyata:"

    data = []

    data << ["1.", "PIHAK KEDUA melakukan pelanggaran dari ketentuan pasal 2 surat perjanjian kerja ini."]
    data << ["2.", "PIHAK KEDUA mangkir selama #{@scope_of_work.agreement_absent_day || 5} hari berturut-turut tanpa pemberitahuan dan atau keterangan dengan bukti yang sah."]
    table(data,
      width: 500,
      column_widths: { 0 => 18 },
      cell_style: { size: 12, inline_format: true, align: :left, valign: :center, border_width: 0 }
    )
  end

  def chapter4
    text "Pasal 4", align: :center, style: :bold
    move_down 5
    data = []
    data << ["1.", "Surat Perjanjian Kerja ini dapat dibatalkan dan atau menjadi tidak berlaku antara lain karena:"]

    sentences = []
    sentences << ["-", "Diakhiri oleh kesepakatan kedua belah pihak walaupun jangka waktu belum berakhir."]
    sentences << ["-", "Dilakukannya pemutusan hubungan kerja oleh PIHAK PERTAMA karena hal-hal sebagaimana diatur dalam Pasal 3 Surat Perjanjian Kerja ini."]
    sentences << ["-", "PIHAK KEDUA meninggal dunia."]

    table(data,
      width: 500,
      column_widths: { 0 => 18 },
      cell_style: { size: 12, inline_format: true, align: :left, valign: :center, border_width: 0 }
    )

    span(450, position: :center) do
      table(sentences,
        width: 450,
        column_widths: { 0 => 18 },
        cell_style: { size: 12, inline_format: true, align: :left, valign: :center, border_width: 0 }
      )
    end

    data1 = []
    data1 << ["2.", "Apabila PIHAK KEDUA berniat untuk mengundurkan diri maka Ia wajib mengajukan surat pengunduran diri kepada PIHAK PERTAMA sekurang-kurangnya 2 (dua) minggu sebelum tanggal diharuskannya PIHAK KEDUA menjalankan kewajibannya."]
    data1 << ["3.", "Masa kontrak ini pada tanggal <b>#{@scope_of_work.agreement_end_date || (Date.today + 7.days).strftime("%d %B %Y")}</b>. Bilamana terdapat perubahan periode campaign, maka PIHAK PERTAMA berkewajiban menginformasikan kepada PIHAK KEDUA untuk kemudian mendapatkan persetujuan."]

    table(data1,
      width: 500,
      column_widths: { 0 => 18 },
      cell_style: { size: 12, inline_format: true, align: :left, valign: :center, border_width: 0 }
    )
  end

  def chapter5
    text "Pasal 5", align: :center, style: :bold
    move_down 5

    data = []
    data << ["1.", "Surat Perjanjian Kerja untuk waktu tertentu ini dibuat dan ditandatangani oleh kedua belah pihak dengan tanpa ada pengaruh dan atau paksaan dari siapapun serta mengikat kedua belah pihak untuk mentaati dan melaksanakannya dengan penuh tanggung jawab."]
    data << ["2.", "Surat Perjanjian ini dibuat dan ditandatangani oleh kedua belah pihak pada tanggal, bulan dan tahun seperti tersebut di bawah dalam rangkap 2 (dua) yang memiliki kekuatan hukum yang sama dan dipegang oleh masing-masing pihak."]

    table(data,
      width: 500,
      column_widths: { 0 => 18 },
      cell_style: { size: 12, inline_format: true, align: :left, valign: :center, border_width: 0 }
    )
  end

  def sign_place_holder
    move_down 50

    text "Jakarta, #{@scope_of_work.updated_at.strftime("%d %B %Y")}", align: :right

    digital_sign = "#{Rails.root}/app/assets/images/digital-sign-agreement.png"

    bounding_box([0, 300], width: 250, height: 150) do
      text "PIHAK PERTAMA", align: :center, style: :bold
      move_down 25
      image digital_sign, width: 150, height: 80, position: :center
      move_down 5
      text "SABRINA FARHANA", align: :center, style: :bold
      text "DIREKTUR MEDIARUMU", align: :center, style: :bold
      transparent(0.5) { stroke_bounds } if debug?
    end

    bounding_box([300, 300], width: 250, height: 150) do
      text "PIHAK KEDUA", align: :center, style: :bold
      move_down 50
      text "Materai 10.000", align: :center, style: :bold
      move_down 45
      text @influencer.name, align: :center, style: :bold
      text "PIHAK INFLUENCER", align: :center, style: :bold
      transparent(0.5) { stroke_bounds } if debug?
    end
  end

  def logo
    # logo from assets/images
    logo = "#{Rails.root}/app/assets/images/logos/logo.jpeg"
    bounding_box([0, 790], width: 100, height: 150) do
      image logo, height: 100, position: :left
      transparent(0.5) { stroke_bounds } if debug?
    end
  end

  def contact_info
    bounding_box([200, 800], width: 350, height: 100) do
      move_down 30
      text "PT Tekno Solusi Mediarumu", align: :right, size: 8
      move_down 5
      text "Recapital Building, 1st Floor", align: :right, size: 8
      move_down 5
      text "Jalan Adityawarman no.55 Jakarta Selatan 12160", align: :right, size: 8
      move_down 5
      text "Phone: 6221-7226825", align: :right, size: 8
    end
  end

  def debug?
    false
  end
end
