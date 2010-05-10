/*
* Copyright (c) 2005-2009 Nokia Corporation and/or its subsidiary(-ies).
* All rights reserved.
* This component and the accompanying materials are made available
* under the terms of the License "Eclipse Public License v1.0"
* which accompanies this distribution, and is available
* at the URL "http://www.eclipse.org/legal/epl-v10.html".
*
* Initial Contributors:
* Nokia Corporation - initial contribution.
*
* Contributors:
*
* Description: 
* @internalComponent 
* @released
*
*/


#include "e32_image_reader.h"

E32ImageReader::E32ImageReader(char *aFile):ImageReader(aFile)
{
}

E32ImageReader::E32ImageReader():ImageReader(NULL)
{
}


E32ImageReader::~E32ImageReader()
{
	delete iE32Image;
}

void E32ImageReader::ReadImage()
{
	ifstream aIf(iImgFileName.c_str(), ios::binary | ios::in);
	if( !aIf.is_open() )
	{
		throw ImageReaderException(iImgFileName.c_str(), "Cannot open file ");
	}

	iE32Image = new E32ImageFile();

	TUint32			aSz;

	aIf.seekg(0,ios::end);
	aSz = aIf.tellg();

	iE32Image->Adjust(aSz);
	iE32Image->iFileSize = aSz;

	aIf.seekg(0,ios::beg);
	aIf >> *iE32Image;
}

void E32ImageReader::Validate()
{
}

void E32ImageReader::ProcessImage()
{
}

void E32ImageReader::Dump()
{
	*out << "Image Name................." << iImgFileName.c_str() << endl;
	DumpE32Attributes(*iE32Image);
}

void E32ImageReader::DumpE32Attributes(E32ImageFile& aE32Image)
{
	bool aContinue = true;

	DumpInHex(const_cast<char *>("Size"), aE32Image.iSize ) << endl;
	DumpInHex(const_cast<char *>("Uids"),aE32Image.iOrigHdr->iUid1);
	DumpInHex(const_cast<char *>(" "),aE32Image.iOrigHdr->iUid2, aContinue);
	DumpInHex(const_cast<char *>(" "),aE32Image.iOrigHdr->iUid3, aContinue);
	DumpInHex(const_cast<char *>(" "),aE32Image.iOrigHdr->iUidChecksum, aContinue) << endl;

	
	DumpInHex(const_cast<char *>("Entry point"), aE32Image.iOrigHdr->iEntryPoint ) << endl;
	DumpInHex(const_cast<char *>("Code start addr") ,aE32Image.iOrigHdr->iCodeBase)<< endl;
	DumpInHex(const_cast<char *>("Data start addr") ,aE32Image.iOrigHdr->iDataBase) << endl;
	DumpInHex(const_cast<char *>("Text size") ,aE32Image.iOrigHdr->iTextSize) << endl;
	DumpInHex(const_cast<char *>("Code size") ,aE32Image.iOrigHdr->iCodeSize) << endl;
	DumpInHex(const_cast<char *>("Data size") ,aE32Image.iOrigHdr->iDataSize) << endl;
	DumpInHex(const_cast<char *>("Bss size") ,aE32Image.iOrigHdr->iBssSize) << endl;
	DumpInHex(const_cast<char *>("Total data size") ,(aE32Image.iOrigHdr->iBssSize + aE32Image.iOrigHdr->iDataSize)) << endl;
	DumpInHex(const_cast<char *>("Heap min") ,aE32Image.iOrigHdr->iHeapSizeMin) << endl;
	DumpInHex(const_cast<char *>("Heap max") ,aE32Image.iOrigHdr->iHeapSizeMax) << endl;
	DumpInHex(const_cast<char *>("Stack size") ,aE32Image.iOrigHdr->iStackSize) << endl;
	DumpInHex(const_cast<char *>("Export directory") ,aE32Image.iOrigHdr->iExportDirOffset) << endl;
	DumpInHex(const_cast<char *>("Export dir count") ,aE32Image.iOrigHdr->iExportDirCount) << endl;
	DumpInHex(const_cast<char *>("Flags") ,aE32Image.iOrigHdr->iFlags) << endl;

	TUint aHeaderFmt = E32ImageHeader::HdrFmtFromFlags(aE32Image.iOrigHdr->iFlags);

	if (aHeaderFmt >= KImageHdrFmt_V)
	{
		//
		// Important. Don't change output format of following security info
		// because this is relied on by used by "Symbian Signed".
		//
		E32ImageHeaderV* v = aE32Image.iHdr;
		DumpInHex(const_cast<char *>("Secure ID"), v->iS.iSecureId) << endl;
		DumpInHex(const_cast<char *>("Vendor ID"), v->iS.iVendorId) << endl;
		DumpInHex(const_cast<char *>("Capability"), v->iS.iCaps[1]);
		DumpInHex(const_cast<char *>(" "), v->iS.iCaps[0], aContinue) << endl;

	}

	*out << "Tools Version..............." << dec << (TUint)aE32Image.iOrigHdr->iToolsVersion.iMajor;
	*out << ".";
	out->width (2);
	*out << dec << (TUint)aE32Image.iOrigHdr->iToolsVersion.iMinor ;
	*out << "(" << dec << aE32Image.iOrigHdr->iToolsVersion.iBuild << ")" << endl;

	*out << "Module Version.............." << dec << (aE32Image.iOrigHdr->iModuleVersion >> 16) << endl;
	DumpInHex(const_cast<char *>("Compression"), aE32Image.iOrigHdr->iCompressionType) << endl;

	if( aHeaderFmt >= KImageHdrFmt_V )
	{
		E32ImageHeaderV* v = aE32Image.iHdr;
		DumpInHex(const_cast<char *>("Exception Descriptor"), v->iExceptionDescriptor) << endl;
		DumpInHex(const_cast<char *>("Code offset"), v->iCodeOffset) << endl;

	}

	*out << "Priority...................." << dec << aE32Image.iOrigHdr->iProcessPriority << endl;
	DumpInHex(const_cast<char *>("Dll ref table size"), aE32Image.iOrigHdr->iDllRefTableCount) << endl << endl << endl;
}

