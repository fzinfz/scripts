using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Office.Interop.Word;
using Microsoft.Office.Interop.Excel;
using System.Reflection;
using System.IO;
using System.Text.RegularExpressions;

namespace WordInterop_CMC
{
    class Program
    {
        static FileInfo[] GetXls()
        {
            List<string> l = new List<string>();
            DirectoryInfo di = new DirectoryInfo("info");
            return di.GetFiles("*.xls");//.ToList().ForEach(x => l.Add(x));
            //return l;
        }

        static string GetDoc_ByXlsName(string name)
        {
            string VolunteerName = Regex.Match(name, "(?<=[ -])[\u0800-\u9fa5]+").Value;

            if (VolunteerName == null || VolunteerName == "") return null;

            DirectoryInfo di = new DirectoryInfo("info");
            FileInfo[] rgFiles = di.GetFiles("*.doc");
            string doc = null;
            foreach (FileInfo fi in rgFiles)
            {
                if (fi.Name.Contains(VolunteerName))
                {
                    doc = fi.FullName;
                    return doc;
                }
            }
            return doc;
        }

        public static string StartupPath
        {
            get
            {
                string AssemblyLocation = Assembly.GetEntryAssembly().Location;
                string startupPath = System.IO.Path.GetDirectoryName(AssemblyLocation) + "\\";
                return startupPath;
            }
        }

        static void Main(string[] args)
        {

            Microsoft.Office.Interop.Excel.Application app_xls = new Microsoft.Office.Interop.Excel.Application();
            Microsoft.Office.Interop.Word.Application app_doc = new Microsoft.Office.Interop.Word.Application();

            Microsoft.Office.Interop.Excel.Workbook wb_result = app_xls.Workbooks.Open(StartupPath + "志愿者报名.xlsx", Editable: true);
            Worksheet ws_result = wb_result.Sheets["auto"];
            int ws_result_StartEditingRow = ws_result.UsedRange.Rows.Count + 1;
            Console.WriteLine("wb_result Start writing from Row " + ws_result_StartEditingRow);

            Microsoft.Office.Interop.Excel.Range xls_names = ws_result.UsedRange.Columns[1];
            object[,] xls_names_value = null;
            if (ws_result.UsedRange.Rows.Count > 1)
                xls_names_value = (object[,])xls_names.get_Value();

            int counting = GetXls().Count();

            try
            {

                foreach (FileInfo xls_fi in GetXls())
                {
                    Console.WriteLine("******************* " + (counting--) + " *****************");
                    int xlsAnalyzed = 0;
                    if (xls_names_value != null)
                    {
                        foreach (var item in xls_names_value)
                        {
                            if (item != null && item.ToString().Contains(xls_fi.Name))
                            {
                                xlsAnalyzed = 1;
                                break;
                            }
                        }
                    }
                    if (xlsAnalyzed == 1) continue;



                    //else start analyzing xls
                    string xls = xls_fi.FullName;
                    Microsoft.Office.Interop.Excel.Workbook wb_single = app_xls.Workbooks.Open(xls, ReadOnly: true);
                    Worksheet ws_raw = wb_single.Sheets[1]; //only 1 sheet

                    //set xls name

                    ((Microsoft.Office.Interop.Excel.Range)ws_result.Cells[ws_result_StartEditingRow, 1]).set_Value(Missing.Value, wb_single.Name.ToString());


                    //copy single to result
                    for (int i = 4; i <= 25; i++)
                    {
                        string c = ((Microsoft.Office.Interop.Excel.Range)ws_raw.Cells[i, 4]).Text;
                        if (c == "") c = ((Microsoft.Office.Interop.Excel.Range)ws_raw.Cells[i-1, 3]).Text;

                        Console.WriteLine(c);
                        ((Microsoft.Office.Interop.Excel.Range)ws_result.Cells[ws_result_StartEditingRow, i - 2]).set_Value(Missing.Value, c);
                    }



                    string doc = GetDoc_ByXlsName(wb_single.Name);

                    Microsoft.Office.Interop.Excel.Range Cell_DocFileName = ws_result.Cells[ws_result_StartEditingRow, 27];

                    if (doc == null)
                        Cell_DocFileName.set_Value(Missing.Value, "DocNotFound");
                    else
                    {

                        Document document = app_doc.Documents.Open(doc, ReadOnly: true);
                        Cell_DocFileName.set_Value(Missing.Value, document.Name);

                        int count = document.FormFields.Count;

                        for (int i = 1; i <= count; i++)
                        {
                            try //for Exception "对象已被删除。"
                            {

                                FormField ff = document.FormFields[i];
                                string name = ff.Name;
                                string value = ff.Result;

                                Console.WriteLine("{0}, {1}", name, value);
                                //Console.Write(text + "\t");

                                //        ((Microsoft.Office.Interop.Excel.Range)ws_result.Cells[1, i + 27]).set_Value(Missing.Value, name);
                                ((Microsoft.Office.Interop.Excel.Range)ws_result.Cells[ws_result_StartEditingRow, i + 27]).set_Value(Missing.Value, value);
                            }
                            catch (Exception e)
                            {
                                Console.WriteLine(e.Message);

                            }
                        }

                    }


                    wb_single.Close(SaveChanges: false);
                    ws_result_StartEditingRow++;


                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                Console.ReadLine();
            }
            finally
            {

                wb_result.Save();
                wb_result.Close(SaveChanges: true);
                app_doc.Quit();
                app_xls.Quit();
                Console.WriteLine("Done!");
                Console.ReadLine();
            }
        }

    }
}

